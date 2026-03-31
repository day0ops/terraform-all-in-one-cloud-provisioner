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

# ----------------------------------------------------------------------------------
# EKS
# ----------------------------------------------------------------------------------

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "eks_region" {
  description = "AWS region for EKS"
  type        = string
  default     = "ap-southeast-2"
}

variable "eks_cluster_count" {
  description = "Number of EKS clusters"
  type        = number
  default     = 1
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_nodes" {
  description = "EKS Kubernetes worker nodes (desired ASG capacity)"
  type        = number
  default     = 2
}

variable "eks_min_nodes" {
  description = "EKS minimum ASG capacity"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "EKS maximum ASG capacity"
  type        = number
  default     = 3
}

variable "eks_node_type" {
  description = "AWS EC2 node instance type"
  type        = string
  default     = "t3.medium"
}

variable "eks_subnets" {
  description = "Number of subnets"
  type        = number
  default     = 2
}

# ----------------------------------------------------------------------------------
# GKE
# ----------------------------------------------------------------------------------

variable "gke_project" {
  description = "GCP Project ID for GKE"
  type        = string
}

variable "gke_region" {
  description = "GCP region for GKE"
  type        = string
  default     = "australia-southeast1"
}

variable "gke_cluster_count" {
  description = "Number of GKE clusters"
  type        = number
  default     = 1
}

variable "gke_cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "gke_node_pool_size" {
  description = "GKE Kubernetes worker nodes"
  type        = number
  default     = 3
}

variable "gke_node_type" {
  description = "GKE node instance type"
  type        = string
  default     = "n1-standard-2"
}
