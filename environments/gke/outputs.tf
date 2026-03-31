output "gke_kubeconfig" {
  value       = join(":", module.gke[*].kubeconfig_path)
  description = "Paths to GKE kubeconfig files"
}

output "gke_kubeconfig_context" {
  value       = [for c in module.gke[*].kubeconfig_context : c]
  description = "GKE kubeconfig context names"
}

output "gke_cluster_name" {
  value       = [for c in module.gke[*].k8s_cluster_name : c]
  description = "GKE cluster names"
}
