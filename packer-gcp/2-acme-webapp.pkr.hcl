#--------------------------------------------------
# Packer Plugins
#--------------------------------------------------
packer {
  required_plugins {
    googlecompute = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/googlecompute"
    }
  }
}


#--------------------------------------------------
# Common Image Metadata
#--------------------------------------------------
variable "image_name" {
  default = "acme-webapp"
}

variable "hcp_bucket_name" {
  default = "acme-webapp"
}

variable "version" {
  default = "1.0.0"
}

variable "hcp_channel_base" {
  default = "production"
}

variable "hcp_channel_webapp" {
  default = "production"
}

variable "hcp_bucket_name_base" {
  default = "acme-base"
}

#--------------------------------------------------
# HCP Packer Registry
# - Base Image Bucket and Channel
#--------------------------------------------------
# Returh the most recent Iteration (or build) of an image, given a Channel
data "hcp-packer-iteration" "acme-base" {
  bucket_name = var.hcp_bucket_name_base
  channel     = var.hcp_channel_base
}


#--------------------------------------------------
# GCE Image Config and Definition
#--------------------------------------------------
variable "gcp_project_id" {
  default = "eric-terraform"
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
  # The key is "region", but in GCE it actually wants the "zone"
  region         = var.gce_zone
  bucket_name    = var.hcp_bucket_name_base
  iteration_id   = data.hcp-packer-iteration.acme-base.id
}

source "googlecompute" "acme-webapp" {
  project_id = var.gcp_project_id
  source_image = data.hcp-packer-image.gce.id
  zone = var.gce_zone
  # The AWS Ubuntu image uses user "ubuntu", so we shall do the same here
  ssh_username = "ubuntu"
}

#--------------------------------------------------
# Common Build Definition
#--------------------------------------------------
build {

  hcp_packer_registry {
    bucket_name = var.hcp_bucket_name
    description = <<EOT
This is the Acme Base + Our "Application" (html)
    EOT
    bucket_labels = {
      "owner"             = "application-team"
      "os"                = "Ubuntu"
      "ubuntu-version"    = "Focal 20.04"
      "image-name"        = var.image_name
    }

    build_labels = {
      "build-time"        = timestamp()
      "build-source"      = basename(path.cwd)
      "acme-base-version" = data.hcp-packer-iteration.acme-base.id
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
