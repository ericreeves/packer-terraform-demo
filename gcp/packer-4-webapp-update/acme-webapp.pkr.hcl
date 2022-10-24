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


#---------------------------------------------------------------------------------------
# HCP Packer Registry
# - Base Image Bucket and Channel
#---------------------------------------------------------------------------------------
# Returh the most recent Iteration (or build) of an image, given a Channel
data "hcp-packer-iteration" "acme-base" {
  bucket_name = var.hcp_base_bucket
  channel     = var.hcp_base_channel
}


#---------------------------------------------------------------------------------------
# GCE Image Config and Definition
#---------------------------------------------------------------------------------------
variable "gcp_project" {
  default = "<UPDATEME - GCP PROJECT NAME>"
}

variable "gce_region" {
  default = "us-central1"
}

variable "gce_zone" {
  default = "us-central1-c"
}

# Retrieve Latest Iteration ID for packer-terraform-demo/gce
data "hcp-packer-image" "gce" {
  cloud_provider = "gce"
  # The key is named "region", but in GCE it actually wants the "zone"
  region       = var.gce_zone
  bucket_name  = var.hcp_base_bucket
  iteration_id = data.hcp-packer-iteration.acme-base.id
}

source "googlecompute" "acme-webapp" {
  project_id   = var.gcp_project
  source_image = data.hcp-packer-image.gce.id
  zone         = var.gce_zone
  # The AWS Ubuntu image uses user "ubuntu", so we shall do the same here
  ssh_username = "ubuntu"
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
      "acme-base-version" = data.hcp-packer-image.gce.labels.acme-base-version
      "acme-app-version"  = var.version
    }
  }

  sources = [
    "sources.googlecompute.acme-webapp"
  ]

  provisioner "file" {
    source      = "files/deploy-app.sh"
    destination = "/tmp/deploy-app.sh"
  }

  provisioner "shell" {
    inline = ["bash /tmp/deploy-app.sh"]
  }
}