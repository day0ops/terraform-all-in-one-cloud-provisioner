output "eks_ipv6_kubeconfig" {
  value       = join(":", module.eks_ipv6[*].kubeconfig_path)
  description = "Colon-separated paths to EKS IPv6 kubeconfig files"
}

output "eks_ipv6_kubeconfig_context" {
  value       = [for c in module.eks_ipv6[*].kubeconfig_context : c]
  description = "EKS IPv6 kubeconfig context names"
}

output "eks_ipv6_cluster_name" {
  value       = [for c in module.eks_ipv6[*].k8s_cluster_name : c]
  description = "EKS IPv6 cluster names"
}

output "eks_ipv6_configure_kubectl" {
  value       = [for c in module.eks_ipv6[*].configure_kubectl : c]
  description = "aws eks update-kubeconfig commands for each cluster"
}
