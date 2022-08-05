packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
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
  default = "1.0.0"
}

variable "dockerhub_username" {
  default = env("DOCKERHUB_USERNAME")
}

variable "dockerhub_password" {
  default = env("DOCKERHUB_PASSWORD")
}

source "docker" "ubuntu" {
  image   = "ubuntu:22.04"
  commit  = true
  changes = [
      "EXPOSE 80",
      "CMD [\"/usr/sbin/apache2ctl\", \"-DFOREGROUND\"]"
  ]
}

build {
  hcp_packer_registry {
    bucket_name = var.hcp_bucket_name
    description = <<EOT
This is the base Ubuntu image + Our "Platform" (apache2)
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
    "source.docker.ubuntu",
  ]

  provisioner "shell" {
    inline = [
      "apt -y update",
      "apt -y install apache2"
    ]

  }

  post-processors {
    post-processor "docker-tag" {
      repository = "ericreeves/acme-base"
      tags       = ["1.0"]
    }
    post-processor "docker-push" {
      login = true
      login_username = var.dockerhub_username
      login_password = var.dockerhub_password
    }
  }
}

