output "k8s_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "kubeconfig_path" {
  description = "Absolute path to the generated kubeconfig file"
  value       = abspath("${path.module}/output/kubeconfig-${local.kubeconfig_context}")
}

output "kubeconfig_context" {
  description = "Kubeconfig context name"
  value       = local.kubeconfig_context
}

output "configure_kubectl" {
  description = "aws eks update-kubeconfig command for this cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_ipv6_cidr_block" {
  description = "VPC IPv6 CIDR block (used for Transit Gateway cross-cluster routing)"
  value       = module.vpc.vpc_ipv6_cidr_block
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_route_table_ids" {
  description = "List of private route table IDs (used for Transit Gateway cross-cluster routing)"
  value       = module.vpc.private_route_table_ids
}
