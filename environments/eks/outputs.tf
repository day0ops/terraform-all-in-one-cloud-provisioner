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

output "eks_dns_zone_id" {
  value       = try(module.eks[0].dns_zone_id, null)
  description = "Route53 child hosted zone ID"
}

output "eks_dns_zone_name" {
  value       = try(module.eks[0].dns_zone_name, null)
  description = "Route53 child hosted zone name"
}

output "eks_dns_nameservers" {
  value       = try(module.eks[0].dns_nameservers, [])
  description = "Nameservers for the child hosted zone"
}
