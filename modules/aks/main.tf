locals {
  count = var.enable_aks ? 1 : 0
}

# Random identifier for cluster name suffix
resource "random_id" "aks_cluster_name_suffix" {
  count = local.count

  byte_length = 6
}

# Get the current workstation public IP
data "http" "workstation_public_ip" {
  count = local.count

  url = "http://ipv4.icanhazip.com"
}

data "azurerm_kubernetes_service_versions" "aks_current_k8s_version" {
  count = local.count

  location = var.aks_region

  depends_on = [azurerm_resource_group.aks_resource_group]
}

locals {
  provider_type           = "aks"
  cluster_name            = try(join("-", [format("%v-%v-%v", var.owner, var.aks_cluster_name, random_id.aks_cluster_name_suffix.0.hex), var.aks_cluster_index]), "")
  kubeconfig_context      = try(format("%v-%v", local.provider_type, local.cluster_name), "")
  k8s_version             = try(var.kubernetes_version, "")
  dns_prefix              = try(format("%v-%v", substr(format("%v%v", var.aks_cluster_name, random_id.aks_cluster_name_suffix.0.hex), 0, 40), var.aks_cluster_index), "")
  node_pool_name          = "nodepool"
  workstation_public_cidr = var.aks_restrict_workstation_access ? split(",", try("${chomp(data.http.workstation_public_ip.0.response_body)}/32", "")) : null
  tags = merge(
    {
      "provider"   = local.provider_type
      "cluster"    = local.cluster_name
      "created-by" = var.owner
      "team"       = var.team
      "purpose"    = var.purpose
      "managed-by" = "terraform"
    },
    var.extra_tags
  )
  default_agent_profile = {
    os_type           = "Linux"
    type              = "VirtualMachineScaleSets"
    max_pods          = 30
    os_disk_size_gb   = 50
    os_sku            = "Ubuntu"
    os_disk_type      = "Managed"
    kubelet_disk_type = "OS"
  }
  agent_pool_availability_zones_lb = [var.aks_availability_zones != null ? "Standard" : ""]
  load_balancer_sku                = coalesce(flatten([local.agent_pool_availability_zones_lb, ["standard"]])...)

  # Diagnostics related
  diag_resource_list = var.aks_diagnostics != null ? split("/", var.aks_diagnostics.destination) : []
  parsed_diag = var.aks_diagnostics != null ? {
    log_analytics_id = contains(local.diag_resource_list, "Microsoft.OperationalInsights") ? var.aks_diagnostics.destination : null
    log              = var.aks_diagnostics.logs
    } : {
    log_analytics_id = null
    log              = []
  }
}

resource "azurerm_resource_group" "aks_resource_group" {
  count = local.count

  name     = "${local.cluster_name}-rg"
  location = var.aks_region

  tags = local.tags
}

resource "azurerm_virtual_network" "aks_vnet" {
  count = local.count

  name                = "${local.cluster_name}-vnet"
  location            = azurerm_resource_group.aks_resource_group.0.location
  resource_group_name = azurerm_resource_group.aks_resource_group.0.name
  address_space       = var.aks_vnet_cidr_block

  tags = local.tags
}

resource "azurerm_subnet" "aks_subnet" {
  count = local.count

  name                 = "${local.cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.aks_resource_group.0.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.0.name
  address_prefixes     = var.aks_vnet_subnet_cidr_block
}

resource "azurerm_kubernetes_cluster" "aks_master" {
  count = local.count

  name                      = local.cluster_name
  location                  = azurerm_resource_group.aks_resource_group.0.location
  resource_group_name       = azurerm_resource_group.aks_resource_group.0.name
  dns_prefix                = local.cluster_name
  kubernetes_version        = try(try(local.k8s_version, data.azurerm_kubernetes_service_versions.aks_current_k8s_version.0.latest_version), null)
  node_resource_group       = local.cluster_name
  automatic_channel_upgrade = var.aks_automatic_channel_upgrade

  azure_policy_enabled = var.aks_addons.policy

  role_based_access_control_enabled = true

  api_server_access_profile {
    authorized_ip_ranges = local.workstation_public_cidr
  }

  # FIXME: It doesnt look there is a way to drain the default pool today.
  # So we create a small pool of 1
  default_node_pool {
    name                 = "defaultpool"
    vm_size              = "Standard_D2_v2"
    zones                = null
    node_count           = 1
    min_count            = null
    max_count            = null
    type                 = local.default_agent_profile.type
    vnet_subnet_id       = azurerm_subnet.aks_subnet.0.id
    node_taints          = null
    orchestrator_version = local.k8s_version
    enable_auto_scaling  = false
    max_pods             = local.default_agent_profile.max_pods
    os_sku               = local.default_agent_profile.os_sku
    os_disk_size_gb      = local.default_agent_profile.os_disk_size_gb
    os_disk_type         = local.default_agent_profile.os_disk_type
    kubelet_disk_type    = local.default_agent_profile.kubelet_disk_type
    node_labels          = local.tags
  }

  service_principal {
    client_id     = var.aks_service_principal.client_id
    client_secret = var.aks_service_principal.client_secret
  }

  dynamic "oms_agent" {
    for_each = var.aks_addons.log_analytics_workspace_enabled ? ["oms_agent"] : []

    content {
      log_analytics_workspace_id = var.aks_addons.oms_agent_workspace_id
    }
  }

  dynamic "linux_profile" {
    for_each = var.worker_node_authentication != null ? [true] : []
    iterator = lp

    content {
      admin_username = var.worker_node_authentication.username

      ssh_key {
        key_data = var.worker_node_authentication.ssh_key
      }
    }
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    dns_service_ip = cidrhost(var.aks_service_cidr_block, 10)
    service_cidr   = var.aks_service_cidr_block

    # Use Standard if availability zones are set, Basic otherwise
    load_balancer_sku = local.load_balancer_sku
  }

  tags = local.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_workers" {
  count = local.count

  name                  = local.node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_master.0.id
  vm_size               = var.aks_node_type
  zones                 = var.aks_availability_zones
  orchestrator_version  = local.k8s_version
  enable_auto_scaling   = var.aks_enable_nodes_auto_scaling
  node_count            = var.aks_nodes
  min_count             = var.aks_min_nodes
  max_count             = var.aks_max_nodes
  max_pods              = local.default_agent_profile.max_pods
  os_sku                = local.default_agent_profile.os_sku
  os_disk_size_gb       = local.default_agent_profile.os_disk_size_gb
  os_disk_type          = local.default_agent_profile.os_disk_type
  os_type               = local.default_agent_profile.os_type
  kubelet_disk_type     = local.default_agent_profile.kubelet_disk_type
  vnet_subnet_id        = azurerm_subnet.aks_subnet.0.id

  tags = local.tags
}

data "azurerm_monitor_diagnostic_categories" "aks_diagnostic_categories" {
  count = (local.count > 0) ? ((var.aks_diagnostics != null) ? 1 : 0) : 0

  resource_id = azurerm_kubernetes_cluster.aks_master.0.id
}

# Enable diagnostics

resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic" {
  count = (local.count > 0) ? ((var.aks_diagnostics != null) ? 1 : 0) : 0

  name                       = "${local.cluster_name}-diag"
  target_resource_id         = azurerm_kubernetes_cluster.aks_master.0.id
  log_analytics_workspace_id = local.parsed_diag.log_analytics_id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.aks_diagnostic_categories.0.log_category_types
    content {
      category = log.value
      enabled  = contains(local.parsed_diag.log, "all") || contains(local.parsed_diag.log, log.value)

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }
}

# Assign roles

# resource "azurerm_role_assignment" "aks_roles_subnet" {
#   count = local.count

#   scope                = azurerm_subnet.aks_subnet.0.id
#   role_definition_name = "Network Contributor"
#   principal_id         = var.aks_service_principal.object_id
# }

resource "azurerm_role_assignment" "aks_roles_identities" {
  count = (local.count > 0) ? length(var.aks_managed_identities) : 0

  scope                = var.aks_managed_identities[count.index]
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_service_principal.object_id

  // For now ignore changes for scope because of lower/upper case issue with resourceId forces a recreate of this resource.
  lifecycle {
    ignore_changes = [scope]
  }
}

data "azurerm_kubernetes_cluster" "aks_kubeconfig" {
  count = local.count

  name                = azurerm_kubernetes_cluster.aks_master.0.name
  resource_group_name = azurerm_kubernetes_cluster.aks_master.0.resource_group_name
}

data "template_file" "kubeconfig_tpl" {
  count = local.count

  template = file("${path.module}/files/kubeconfig-template.tpl")

  vars = {
    context                = local.kubeconfig_context
    endpoint               = data.azurerm_kubernetes_cluster.aks_kubeconfig.0.kube_config.0.host
    cluster_ca_certificate = data.azurerm_kubernetes_cluster.aks_kubeconfig.0.kube_config.0.cluster_ca_certificate
    client_certificate     = data.azurerm_kubernetes_cluster.aks_kubeconfig.0.kube_config.0.client_certificate
    client_key             = data.azurerm_kubernetes_cluster.aks_kubeconfig.0.kube_config.0.client_key
    cluster_name           = local.cluster_name
  }

  depends_on = [data.azurerm_kubernetes_cluster.aks_kubeconfig]
}

resource "local_file" "kubeconfig_tpl_renderer" {
  count = local.count

  content  = data.template_file.kubeconfig_tpl.0.rendered
  filename = "${path.module}/output/kubeconfig-aks-${var.aks_cluster_index}"
}

// -----

# ## Log Analytics for Container logs (enable_logs = true)
# resource "azurerm_log_analytics_workspace" "logworkspace" {
#   count               = var.enable_microsoft && var.enable_logs ? 1 : 0
#   name                = "${var.aks_name}-${random_id.cluster_name[count.index].hex}-law"
#   location            = azurerm_resource_group.rg[count.index].location
#   resource_group_name = azurerm_resource_group.rg[count.index].name
#   sku                 = "PerGB2018"
# }

# resource "azurerm_log_analytics_solution" "logsolution" {
#   count                 = var.enable_microsoft && var.enable_logs ? 1 : 0
#   solution_name         = "ContainerInsights"
#   location              = azurerm_resource_group.rg[count.index].location
#   resource_group_name   = azurerm_resource_group.rg[count.index].name
#   workspace_resource_id = azurerm_log_analytics_workspace.logworkspace[count.index].id
#   workspace_name        = azurerm_log_analytics_workspace.logworkspace[count.index].name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/ContainerInsights"
#   }
# }


# ## Static Public IP Address to be used e.g. by Nginx Ingress
# resource "azurerm_public_ip" "public_ip" {
#   count               = var.enable_microsoft ? 1 : 0
#   name                = "k8s-public-ip-${random_id.cluster_name[count.index].hex}"
#   location            = azurerm_kubernetes_cluster.aks[count.index].location
#   resource_group_name = azurerm_kubernetes_cluster.aks[count.index].node_resource_group
#   allocation_method   = "Static"
#   domain_name_label   = "${var.aks_name}-${random_id.cluster_name[count.index].hex}"
# }

# ## kubeconfig file
# resource "local_file" "kubeconfigaks" {
#   count    = var.enable_microsoft ? 1 : 0
#   content  = azurerm_kubernetes_cluster.aks[count.index].kube_config_raw
#   filename = "${path.module}/kubeconfig_aks"
# }
