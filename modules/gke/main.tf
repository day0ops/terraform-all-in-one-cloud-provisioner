locals {
  count = var.enable_gke ? 1 : 0
}

# Random identifier for cluster name suffix
resource "random_id" "gke_cluster_name_suffix" {
  count = local.count

  byte_length = 6
}

# Get the current workstation public IP
data "http" "workstation_public_ip" {
  count = local.count

  url = "http://ipv4.icanhazip.com"
}

# Get all the available zones for the given region
data "google_compute_zones" "gke_available_zones" {
  count = local.count

  project = var.gke_project
  region  = var.gke_region
  status  = "UP"
}

# Get the latest version available in the computed zone
data "google_container_engine_versions" "gke_current_k8s_version" {
  count = local.count

  project  = var.gke_project
  location = data.google_compute_zones.gke_available_zones[count.index].names[0]
}

locals {
  provider_type           = "gke"
  cluster_name            = try(join("-", [format("%v-%v-%v", var.owner, var.gke_cluster_name, random_id.gke_cluster_name_suffix.0.hex), var.gke_cluster_index]), "")
  kubeconfig_context      = try(format("%v-%v", local.provider_type, local.cluster_name), "")
  node_pool_name          = try(format("%v-node", local.cluster_name), "")
  k8s_version             = try(tostring(try(var.kubernetes_version, data.google_container_engine_versions.gke_current_k8s_version.0.release_channel_default_version["STABLE"])), "")
  workstation_public_cidr = try("${chomp(data.http.workstation_public_ip.0.response_body)}/32", "")
  all_service_account_roles = concat(var.gke_serviceaccount_roles, [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])
  labels = merge(
    {
      "provider"   = local.provider_type
      "cluster"    = local.cluster_name
      "owner"      = var.owner
      "team"       = var.team
      "purpose"    = var.purpose
      "managed-by" = "terraform"
    },
    var.extra_labels
  )
  tags = concat([
    "${local.cluster_name}",
    var.owner,
    var.team,
    var.purpose,
    "terraform"
  ], var.extra_tags)
}

resource "google_service_account" "gke_service_account" {
  count = local.count

  project      = var.gke_project
  account_id   = format("%v-sa", local.cluster_name)
  display_name = var.gke_serviceaccount_description
}

resource "google_project_iam_member" "gke_service_account_roles" {
  for_each = var.enable_gke ? toset(local.all_service_account_roles) : []
  project  = var.gke_project
  role     = each.value
  member   = "serviceAccount:${google_service_account.gke_service_account.0.email}"
}

resource "google_container_cluster" "gke_master" {
  count = local.count

  project            = var.gke_project
  name               = local.cluster_name
  location           = var.enable_gke_regional_cluster ? var.gke_region : data.google_compute_zones.gke_available_zones[count.index].names[0]
  min_master_version = local.k8s_version
  node_version       = local.k8s_version

  # Remove the default node pool once provisioned since we manage this separately
  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    service_account = try(google_service_account.gke_service_account.0.email, var.gke_serviceaccount)
  }

  release_channel {
    channel = "STABLE"
  }

  addons_config {
    # L7 load balancing (Disabled)
    http_load_balancing {
      disabled = false
    }

    # Enabling horizontal pod autoscaling
    horizontal_pod_autoscaling {
      disabled = !var.enable_gke_hpa
    }
  }

  # Network (cidr) from which cluster is accessible (Required for private cluster, optional otherwise)
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "gke-admin"
      cidr_block   = local.workstation_public_cidr
    }
  }

  resource_labels = { for key, value in local.labels : lower(key) => lower(value) }
}

resource "google_container_node_pool" "gke_workers" {
  count = local.count

  project    = var.gke_project
  name       = local.node_pool_name
  location   = var.enable_gke_regional_cluster ? var.gke_region : data.google_compute_zones.gke_available_zones[count.index].names[0]
  cluster    = google_container_cluster.gke_master[count.index].name
  node_count = var.gke_node_pool_size
  version    = local.k8s_version

  node_config {
    image_type      = var.gke_node_image_type
    preemptible     = var.enable_gke_preemptible
    machine_type    = var.gke_node_type
    service_account = var.gke_serviceaccount

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = var.gke_oauth_scopes
    tags         = local.tags
    labels       = local.labels
  }
}

data "google_client_config" "gke_config" {}

data "template_file" "kubeconfig_tpl" {
  count = local.count

  template = file("${path.module}/files/kubeconfig-template.tpl")

  vars = {
    context                = local.kubeconfig_context
    endpoint               = google_container_cluster.gke_master.0.endpoint
    cluster_ca_certificate = google_container_cluster.gke_master.0.master_auth.0.cluster_ca_certificate
  }
}

resource "local_file" "kubeconfig_tpl_renderer" {
  count = local.count

  content  = data.template_file.kubeconfig_tpl.0.rendered
  filename = "${path.module}/output/kubeconfig-gke-${var.gke_cluster_index}"
}
