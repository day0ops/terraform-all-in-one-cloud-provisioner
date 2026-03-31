provider "azurerm" {
  features {}
}

provider "aws" {
  region  = var.eks_region
  profile = var.aws_profile
}
