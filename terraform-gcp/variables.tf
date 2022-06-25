##############################################################################
# Variables File
#
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)

# GCP Service account region and authentication 
variable  "gcp_credentials"{
  description = "Service Account JSON Key File"
  default = "gcp-key.json"
}

variable "project" {
  default = "eric-terraform"
}
variable "region" {
    default = "us-central1"
}

variable "zone" {
    default = "us-central1-c"
}
# VPC INFO
    variable "vnet_name" {
      default = "terraform-network"
    }
    
    variable "subnet-02_cidr" {
      default = "192.168.0.0/16"
    }

# SUBNET INFO
    variable "subnet_name"{
      default = "terraform-subnet" 
      }

    variable "subnet_cidr"{
      default = "192.168.10.0/24"
      } 
  variable "firewall_name" {
    default = "terraform-firewall"
  }

 
variable "subnetwork_project" {
  description = "The project that subnetwork belongs to"
  default     = "eric-terraform"
}

variable "instances_name" {
  description = "Number of instances to create. This value is ignored if static_ips is provided."
  default     = "terravm"
}

variable "admin" {
  description = "OS user"
  default  = "ubuntu"
}

# VNIC INFO
        variable "private_ip" {
        default = "192.168.10.51"
      }
      
variable "hostname" {
  description = "Hostname of instances"
  default     = "web-app-1.alluvium.com"
}
  

# COMPUTE INSTANCE INFO

      variable "instance_name" {
        default = "terraform-webapp"
      }


      variable "osdisk_size" {
        default = "30"
      }
      variable "vm_type" {   # gcloud compute machine-types list --filter="zone:us-east1-b and name:e2-micro"
        default = "e2-micro" #"f1-micro"
      }

variable  "os_image" {
	default = "ubuntu-os-cloud/ubuntu-2004-lts"
}

