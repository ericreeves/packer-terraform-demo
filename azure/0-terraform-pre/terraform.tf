# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.1.0"
    }
  }

  cloud {
    organization = "ericreeves-demo"
    hostname     = "app.terraform.io"

    workspaces {
      name = "packer-azure-init"
    }
  }
}

# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
}
