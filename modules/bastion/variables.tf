variable "enable" {
  description = "Activate bastion in the VPC (Default: false)"
  type        = bool
  default     = false
}

variable "owner" {
  description = "Name of the maintainer of the cluster"
  type        = string
}

variable "prefix_name" {
  description = "Prefix name for bastion host resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the bastion will be hosted"
  type        = string
}

variable "elb_subnets" {
  description = "Subnet IDs for the Network Load Balancer"
  type        = list(string)
}

variable "auto_scaling_group_subnets" {
  description = "Subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "bastion_ssh_key" {
  description = "SSH key name for bastion host access"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for all bastion resources"
  type        = map(string)
  default     = {}
}
