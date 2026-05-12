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

output "dns_zone_id" {
  value       = try(aws_route53_zone.child[0].zone_id, null)
  description = "Route53 child zone ID"
}

output "dns_zone_name" {
  value       = try(aws_route53_zone.child[0].name, null)
  description = "Route53 child zone name"
}

output "dns_nameservers" {
  value       = try(aws_route53_zone.child[0].name_servers, [])
  description = "Route53 child zone nameservers"
}