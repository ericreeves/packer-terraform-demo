terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.23.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }

  cloud {
    organization = "<UPDATEME - ORGANIZATION NAME>"
    # For Terraform Enterprise, replace this with the hostname of your TFE instance
    hostname     = "app.terraform.io"

    workspaces {
      name = "<UPDATEME - WORKSPACE NAME>"
    }
  }
}
