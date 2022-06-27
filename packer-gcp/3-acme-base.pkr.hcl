#---------------------------------------------------------------------------------------
# Packer Plugins
#---------------------------------------------------------------------------------------
packer {
  required_plugins {
    googlecompute = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

#---------------------------------------------------------------------------------------
# Common Image Metadata
#---------------------------------------------------------------------------------------
variable "hcp_bucket_name" {
  default = "acme-base"
}

variable "image_name" {
  default = "acme-base"
}

variable "version" {
  default = "2.0.0"
}

#---------------------------------------------------------------------------------------
# GCE Image Config and Definition
#---------------------------------------------------------------------------------------
variable "gcp_project_id" {
  default = "eric-terraform"
}

variable "gce_region" {
  default = "us-central1"
}

variable "gce_zone" {
  default = "us-central1-c"
}

variable "gce_source_image" {
  default = "ubuntu-2004-focal-v20220615"
}

source "googlecompute" "acme-base" {
  project_id   = var.gcp_project_id
  source_image = var.gce_source_image
  zone         = var.gce_zone
  # The AWS Ubuntu image uses user "ubuntu", so we shall do the same here
  ssh_username = "ubuntu"
}

#---------------------------------------------------------------------------------------
# Common Build Definition
#---------------------------------------------------------------------------------------
build {

  hcp_packer_registry {
    bucket_name = var.hcp_bucket_name
    description = <<EOT
This is the base Ubuntu image + Our "Platform" (nginx)
    EOT
    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu"
      "ubuntu-version" = "Focal 20.04"
      "image-name"     = var.image_name
    }

    build_labels = {
      "build-time"        = timestamp()
      "build-source"      = basename(path.cwd)
      "acme-base-version" = var.version
    }
  }

  sources = [
    "sources.googlecompute.acme-base"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt -y update",
      "sudo apt -y install nginx",
      "sudo ufw allow 'Nginx HTTP'",
      "sudo systemctl enable nginx",
      "sudo systemctl status nginx",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
    ]

  }
}
