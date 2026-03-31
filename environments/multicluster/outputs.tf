output "aks_kubeconfig" {
  value       = join(":", module.aks[*].kubeconfig_path)
  description = "Paths to AKS kubeconfig files"
}

output "aks_kubeconfig_context" {
  value       = [for c in module.aks[*].kubeconfig_context : c]
  description = "AKS kubeconfig context names"
}

output "aks_cluster_name" {
  value       = [for c in module.aks[*].k8s_cluster_name : c]
  description = "AKS cluster names"
}

output "eks_kubeconfig" {
  value       = join(":", module.eks[*].kubeconfig_path)
  description = "Paths to EKS kubeconfig files"
}

output "eks_kubeconfig_context" {
  value       = [for c in module.eks[*].kubeconfig_context : c]
  description = "EKS kubeconfig context names"
}

output "eks_cluster_name" {
  value       = [for c in module.eks[*].k8s_cluster_name : c]
  description = "EKS cluster names"
}

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
