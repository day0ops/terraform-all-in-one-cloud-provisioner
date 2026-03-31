module "defaults" {
  source = "../../modules/defaults"
}

module "gke" {
  source = "../../modules/gke"
  count  = var.gke_cluster_count

  enable_gke                  = true
  gke_project                 = var.gke_project
  gke_region                  = var.gke_region
  gke_cluster_name            = var.gke_cluster_name
  gke_cluster_index           = count.index + 1
  enable_gke_regional_cluster = false
  gke_node_pool_size          = var.gke_node_pool_size
  gke_node_type               = var.gke_node_type
  enable_gke_hpa              = true
  kubernetes_version          = coalesce(var.kubernetes_version, module.defaults.kubernetes_version)

  owner   = var.owner
  team    = var.team
  purpose = var.purpose
}
