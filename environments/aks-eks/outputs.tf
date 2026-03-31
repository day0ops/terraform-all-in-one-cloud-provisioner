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
