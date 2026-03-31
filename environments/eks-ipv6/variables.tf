# ----------------------------------------------------------------------------------
# Common
# ----------------------------------------------------------------------------------

variable "owner" {
  description = "Name of the maintainer of the cluster"
  type        = string

  validation {
    condition     = length(var.owner) > 0
    error_message = "Maintainer of the cluster must be provided."
  }
}

variable "team" {
  description = "Team that maintains the cluster"
  type        = string
  default     = "fe-presale"
}

variable "purpose" {
  description = "Purpose for the cluster"
  type        = string
  default     = "pre-sales"
}

variable "kubernetes_version" {
  description = "Override Kubernetes version (default from modules/defaults)"
  type        = string
  default     = null
}

variable "extra_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------------------------------
# AWS
# ----------------------------------------------------------------------------------

variable "aws_profile" {
  description = "AWS CLI profile (leave empty for default credential chain)"
  type        = string
  default     = ""
}

variable "eks_ipv6_region" {
  description = "AWS region for EKS IPv6 clusters"
  type        = string
  default     = "ap-southeast-2"
}

variable "max_availability_zones" {
  description = "Maximum number of availability zones per cluster"
  type        = number
  default     = 2
}

variable "ec2_ssh_key" {
  description = "SSH key name for instance access"
  type        = string
  default     = null
}

variable "create_cni_ipv6_iam_policy" {
  description = "Create AmazonEKS_CNI_IPv6_Policy (only one cluster per account)"
  type        = bool
  default     = false
}

# ----------------------------------------------------------------------------------
# EKS IPv6
# ----------------------------------------------------------------------------------

variable "eks_ipv6_cluster_count" {
  description = "Number of EKS IPv6 clusters to provision"
  type        = number
  default     = 1
}

variable "eks_ipv6_cluster_name" {
  description = "EKS IPv6 cluster base name"
  type        = string
}

variable "eks_ipv6_nodes" {
  description = "Desired number of worker nodes per cluster"
  type        = number
  default     = 2
}

variable "eks_ipv6_min_nodes" {
  description = "Minimum ASG capacity per cluster"
  type        = number
  default     = 1
}

variable "eks_ipv6_max_nodes" {
  description = "Maximum ASG capacity per cluster"
  type        = number
  default     = 3
}

variable "eks_ipv6_node_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "enable_dns64" {
  description = "Enable DNS64 for IPv4-only destination reachability from IPv6 pods"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------------
# Bastion
# ----------------------------------------------------------------------------------

variable "enable_bastion" {
  description = "Enable bastion host (attached to the first cluster's VPC)"
  type        = bool
  default     = true
}
