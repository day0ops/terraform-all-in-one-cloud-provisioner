variable "enable_eks" {
  description = "Enable / Disable Amazon Web Services EKS (Default: `false`)"
  type        = bool
  default     = false
}

variable "eks_region" {
  description = "AWS region for EKS (Default: `ap-southeast-2`, Ref: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS cli profile (Default: `default`)"
  type        = string
  default     = "default"
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_cluster_index" {
  description = "EKS cluster index when multiple clusters are required"
  type        = string
}

variable "eks_nodes" {
  description = "EKS Kubernetes worker nodes, desired ASG capacity (e.g. `2`)"
  type        = number
  default     = 2
}

variable "eks_min_nodes" {
  description = "EKS Kubernetes worker nodes, minimum ASG capacity (e.g. `1`)"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "EKS Kubernetes worker nodes, maximum ASG capacity (e.g. `3`)"
  type        = number
  default     = 3
}

variable "eks_node_type" {
  description = "AWS EC2 node instance type (Default: `t3.medium`, Ref: https://aws.amazon.com/ec2/instance-types)"
  type        = string
  default     = "t3.medium"
}

variable "eks_cidr_block" {
  description = "AWS VPC CIDR block (Default: `10.0.0.0/16`)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_subnets" {
  description = "List of 8-bit numbers of subnets (Default: `2`)"
  type        = number
  default     = 2
}

variable "kubernetes_version" {
  description = "Kubernetes version. If not specified the current stable version is used"
  type        = string
  default     = null
}

# -- Tagging and labeling

variable "owner" {
  description = "Name of the maintainer of the EKS cluster"
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

variable "extra_tags" {
  description = "Tags used for the EKS resources"
  type        = map(string)
  default     = {}
}