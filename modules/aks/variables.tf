variable "enable_aks" {
  description = "Enable / Disable Microsoft AKS (Default: `false`)"
  type        = bool
  default     = false
}

variable "aks_region" {
  description = "Azure region for AKS (Default: `Australia East`, Ref: https://docs.microsoft.com/en-us/azure/aks/availability-zones)"
  type        = string
  default     = "Australia East"
}

variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "aks_cluster_index" {
  description = "AKS cluster index when multiple clusters are required"
  type        = string
}

variable "aks_nodes" {
  description = "AKS worker nodes (e.g. `2`)"
  type        = number
  default     = 2
}

variable "aks_enable_nodes_auto_scaling" {
  description = "Enable autoscaling for AKS worker nodes based on minimum and maximum limits set below (Default: `false`)"
  type        = bool
  default     = false
}

variable "aks_min_nodes" {
  description = "AKS worker nodes minimum node count"
  type        = number
  default     = null
}

variable "aks_max_nodes" {
  description = "AKS worker nodes maximum node count"
  type        = number
  default     = null
}

variable "aks_node_type" {
  description = "Azure node pool instance type (Default: `Standard_D2_v2`, Ref: https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs)"
  type        = string
  default     = "Standard_D2_v2"
}

variable "aks_availability_zones" {
  description = "To spread the nodes in this node pool across multiple physical locations"
  type        = list(string)
  default     = null
}

variable "aks_vnet_cidr_block" {
  description = "Azure AKS virtual network CIDR block (Default: `192.168.0.0/16`)"
  type        = list(string)
  default     = ["192.168.0.0/16"]
}

variable "aks_vnet_subnet_cidr_block" {
  description = "Azure AKS subnet CIDR block (Default: `10.0.0.0/16`)"
  type        = list(string)
  default     = ["192.168.1.0/24"]
}

variable "aks_service_cidr_block" {
  description = "Azure AKS service CIDR block (Default: `10.0.0.0/16`)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version. If not specified the current stable version is used"
  type        = string
  default     = null
}

variable "worker_node_authentication" {
  description = "Worker node authentication that includes path to the SSH public key (e.g. `~/.ssh/id_rsa.pub`) and username"
  type        = map(string)
  default     = null
}

variable "aks_service_principal" {
  description = "Service principal to connect to AKS cluster"
  type = object({
    object_id     = string
    client_id     = string
    client_secret = string
  })
}

variable "aks_addons" {
  description = "Addons to enable / disable for AKS cluster (Default: Azure policy enabled)"
  type = object({
    log_analytics_workspace_enabled = bool
    oms_agent_workspace_id          = string
    policy                          = bool
  })
  default = {
    log_analytics_workspace_enabled = false
    oms_agent_workspace_id          = null
    policy                          = true
  }
}

variable "aks_managed_identities" {
  description = "List of managed identities where the AKS service principal should have access"
  type        = list(string)
  default     = []
}

variable "aks_diagnostics" {
  description = "Diagnostic settings for those resources such as Log Analytics that support it"
  type = object({
    destination = string
    logs        = list(string)
  })
  default = null
}

# -- Tagging and labeling

variable "owner" {
  description = "Name of the maintainer of the AKS cluster"
  type        = string
}

variable "team" {
  description = "Team that maintains the cluster"
  type        = string
}

variable "purpose" {
  description = "Purpose for the cluster"
  type        = string
}

variable "extra_tags" {
  description = "Tags used for the AKS resources"
  type        = map(string)
  default     = {}
}


/// -----




# variable "enable_logs" {
#   description = "Enable azure log analtics for container logs"
#   type        = bool
#   default     = false
# }

# variable "ssh_public_key" {
#   description = "Path to your SSH public key (e.g. `~/.ssh/id_rsa.pub`)"
#   type        = string
#   default     = "~/.ssh/id_rsa.pub"
# }

# variable "az_client_id" {
#   description = "Azure Service Principal appId"
#   type        = string
# }

# variable "az_client_secret" {
#   description = "Azure Service Principal password"
#   type        = string
# }

# variable "az_tenant_id" {
#   description = "Azure Service Principal tenant"
#   type        = string
# }

# variable "aks_nodes" {
#   description = "AKS Kubernetes worker nodes (e.g. `2`)"
#   type        = number
#   default     = 2
# }

# variable "aks_node_type" {
#   description = "AKS node pool instance type (e.g. `Standard_D1_v2` => 1vCPU, 3.75 GB RAM)"
#   type        = string
#   default     = "Standard_D1_v2"
# }

# variable "aks_pool_name" {
#   description = "AKS agent node pool name (e.g. `k8s-aks-nodepool`)"
#   type        = string
#   default     = "k8snodepool"
# }

# variable "aks_node_disk_size" {
#   description = "AKS node instance disk size in GB (e.g. `30` => minimum: 30GB, maximum: 1024)"
#   type        = number
#   default     = 30
# }
