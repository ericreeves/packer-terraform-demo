terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.46"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }

  cloud {
    organization = "ericreeves-demo"
    hostname     = "app.terraform.io"

    workspaces {
      name = "packer-azure-webapp"
    }
  }
}

provider "azurerm" {
  features {}
}