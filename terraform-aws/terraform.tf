terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.23.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }

  cloud {
    organization = "<ORGANIZATION NAME>"
    hostname     = "app.terraform.io"

    workspaces {
      name = "<WORKSPACE NAME>"
    }
  }
}
