terraform {
  required_providers {
    google  = {
      source  = "hashicorp/google"
      version = "~> 4.72.1"
    }
    aws     = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.64.0"
    }
  }

  required_version = ">= 1.4.0"
}