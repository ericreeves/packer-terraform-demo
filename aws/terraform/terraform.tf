terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }

  cloud {
    organization = "ericreeves-demo"
    # For Terraform Enterprise, replace this with the hostname of your TFE instance
    hostname = "app.terraform.io"

    workspaces {
      name = "tfc-packer-demo"
    }
  }
}
