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
