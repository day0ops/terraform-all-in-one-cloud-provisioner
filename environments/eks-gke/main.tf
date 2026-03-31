module "defaults" {
  source = "../../modules/defaults"
}

module "eks" {
  source = "../../modules/eks"
  count  = var.eks_cluster_count

  enable_eks         = true
  aws_profile        = var.aws_profile
  eks_region         = var.eks_region
  eks_cluster_name   = var.eks_cluster_name
  eks_cluster_index  = count.index + 1
  eks_nodes          = var.eks_nodes
  eks_min_nodes      = var.eks_min_nodes
  eks_max_nodes      = var.eks_max_nodes
  eks_node_type      = var.eks_node_type
  eks_subnets        = var.eks_subnets
  kubernetes_version = coalesce(var.kubernetes_version, module.defaults.kubernetes_version)

  owner   = var.owner
  team    = var.team
  purpose = var.purpose
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
