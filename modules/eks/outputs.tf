# Kubernetes cluster name
output "k8s_cluster_name" {
  value = "${local.cluster_name}"
}

# Kubernetes master version
output "k8s_master_version" {
  value = "${local.k8s_version}"
}

# Kubeconfig path
output "kubeconfig_path" {
  value = abspath("${path.module}/output/kubeconfig-eks-${var.eks_cluster_index}")
}

# Kubeconfig context
output "kubeconfig_context" {
  value = local.kubeconfig_context
}