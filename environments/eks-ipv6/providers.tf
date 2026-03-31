provider "aws" {
  region  = var.eks_ipv6_region
  profile = var.aws_profile != "" ? var.aws_profile : null
}
