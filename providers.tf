provider "google" {
  project     = var.gke_project
  region      = var.gke_region

  scopes      = [
    # Default scopes
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",

    # Required for google_client_openid_userinfo
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

provider "aws" {
  region      = var.eks_region
  profile     = var.aws_profile
}

provider "azurerm" {
  features {}
}