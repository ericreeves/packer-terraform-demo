#---------------------------------------------------------------------------------------
# Packer Plugins
#---------------------------------------------------------------------------------------
packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


#---------------------------------------------------------------------------------------
# Common Image Metadata
#---------------------------------------------------------------------------------------
variable "image_name" {
  default = "acme-webapp"
}

variable "version" {
  default = "2.0.0"
}

variable "hcp_base_bucket" {
  default = "acme-base"
}

variable "hcp_base_channel" {
  default = "development"
}

variable "hcp_webapp_bucket" {
  default = "acme-webapp"
}

variable "hcp_webapp_channel" {
  default = "development"
}

#--------------------------------------------------
# AWS Image Config and Definition
#--------------------------------------------------
variable "aws_region" {
  default = "us-east-2"
}

data "hcp-packer-image" "aws" {
  cloud_provider = "aws"
  region         = var.aws_region
  bucket_name    = var.hcp_base_bucket
  channel        = var.hcp_base_channel
}

source "amazon-ebs" "acme-webapp" {
  region         = var.aws_region
  source_ami     = data.hcp-packer-image.aws.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "packer_aws_{{timestamp}}_v${var.version}"
}


#---------------------------------------------------------------------------------------
# Common Build Definition
#---------------------------------------------------------------------------------------
build {
  hcp_packer_registry {
    bucket_name = var.hcp_webapp_bucket
    description = <<EOT
This is the Acme Base + Our "Application" (html)
    EOT
    bucket_labels = {
      "owner"          = "application-team"
      "os"             = "Ubuntu"
      "ubuntu-version" = "Focal 20.04"
      "image-name"     = var.image_name
    }

    build_labels = {
      "build-time"        = timestamp()
      "build-source"      = basename(path.cwd)
      "acme-base-version" = data.hcp-packer-image.aws.labels.acme-base-version
      "acme-app-version"  = var.version
    }
  }

  sources = [
    "sources.amazon-ebs.acme-webapp"
  ]

  provisioner "file" {
    source      = "files/deploy-app.sh"
    destination = "/tmp/deploy-app.sh"
  }

  provisioner "shell" {
    inline = ["bash /tmp/deploy-app.sh"]
  }
}