# Kubernetes cluster name
output "k8s_cluster_name" {
  value = "${local.cluster_name}"
}

# Kubernetes master version
output "k8s_master_version" {
  value = try(data.azurerm_kubernetes_service_versions.aks_current_k8s_version.0.latest_version, local.k8s_version)
}

# Kubeconfig path
output "kubeconfig_path" {
  value = abspath("${path.module}/output/kubeconfig-aks-${var.aks_cluster_index}")
}

# Kubeconfig context
output "kubeconfig_context" {
  value = local.kubeconfig_context
}