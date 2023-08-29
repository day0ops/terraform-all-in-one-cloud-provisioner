output "gke_kubeconfig" {
  value = var.enable_gke ? join(":", module.gke[*].kubeconfig_path) : ""
}

output "gke_kubeconfig_context" {
  value = var.enable_gke ? [for c in module.gke[*].kubeconfig_context: c] : []
}

output "gke_cluster_name" {
  value = var.enable_gke ? [for c in module.gke[*].k8s_cluster_name: c] : []
}

output "eks_kubeconfig" {
  value = var.enable_eks ? join(":", module.eks[*].kubeconfig_path) : ""
}

output "eks_kubeconfig_context" {
  value = var.enable_eks ? [for c in module.eks[*].kubeconfig_context: c] : []
}

output "eks_cluster_name" {
  value = var.enable_eks ? [for c in module.eks[*].k8s_cluster_name: c] : []
}

output "aks_kubeconfig" {
  value = var.enable_aks ? join(":", module.aks[*].kubeconfig_path) : ""
}

output "aks_kubeconfig_context" {
  value = var.enable_aks ? [for c in module.aks[*].kubeconfig_context: c] : []
}

output "aks_cluster_name" {
  value = var.enable_aks ? [for c in module.aks[*].k8s_cluster_name: c] : []
}