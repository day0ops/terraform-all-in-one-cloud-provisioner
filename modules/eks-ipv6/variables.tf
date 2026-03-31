# ----------------------------------------------------------------------------------
# Common
# ----------------------------------------------------------------------------------

variable "owner" {
  description = "Name of the maintainer of the cluster"
  type        = string
}

variable "team" {
  description = "Team that maintains the cluster"
  type        = string
}

variable "purpose" {
  description = "Purpose for the cluster"
  type        = string
}

# ----------------------------------------------------------------------------------
# AWS / EKS
# ----------------------------------------------------------------------------------

variable "region" {
  description = "AWS region for EKS (Ref: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)"
  type        = string
}

variable "max_availability_zones" {
  description = "Maximum number of availability zones used for provisioning (Default: `3`)"
  type        = number
  default     = 3
}

variable "public_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256)"
  type        = list(string)
  default     = [0, 1]
}

variable "private_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256)"
  type        = list(string)
  default     = [2, 3]
}

variable "create_cni_ipv6_iam_policy" {
  description = "Create AmazonEKS_CNI_IPv6_Policy (only one cluster per account should set this, see https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2131)"
  type        = bool
  default     = false
}

variable "nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Minimum ASG capacity"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum ASG capacity"
  type        = number
  default     = 3
}

variable "node_type" {
  description = "EC2 instance type for worker nodes (Default: `t3.medium`)"
  type        = string
  default     = "t3.medium"
}

variable "kubernetes_version" {
  description = "Kubernetes version. If not specified the current stable version is used"
  type        = string
  default     = null
}

variable "allow_istio_mutation_webhook_sg" {
  description = "Allow Istio mutation webhook security group rule (Default: `false`)"
  type        = bool
  default     = false
}

variable "ec2_ssh_key" {
  description = "SSH key name for worker node access"
  type        = string
  default     = null
}

variable "enable_bastion_access" {
  description = "Allow SSH from bastion host to EKS nodes (Default: `false`)"
  type        = bool
  default     = false
}

variable "bastion_security_group_id" {
  description = "Security group ID of the bastion host (required when enable_bastion_access is true)"
  type        = string
  default     = null
}

variable "enable_dns64" {
  description = "Synthesize IPv6 addresses for IPv4-only destinations via DNS64 (Default: `true`)"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------------
# Tags
# ----------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
