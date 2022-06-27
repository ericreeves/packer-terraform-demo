#--------------------------------------------------------------------------------------
# GCP Service account region and authentication 
#--------------------------------------------------------------------------------------
variable "gcp_credentials" {
  description = "Service Account JSON Key File"
  default     = "gcp-key.json"
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


#--------------------------------------------------------------------------------------
# VPC
#--------------------------------------------------------------------------------------
variable "vnet_name" {
  default = "terraform-network"
}


#--------------------------------------------------------------------------------------
# Subnets
#--------------------------------------------------------------------------------------
variable "subnet_name" {
  default = "terraform-subnet"
}

variable "subnet_cidr" {
  default = "192.168.10.0/24"
}

# variable "secondary_cidr" {
#   default = "192.168.64.0/24"
# }

variable "firewall_name" {
  default = "terraform-firewall"
}

variable "subnetwork_project" {
  default     = "eric-terraform"
}

variable "instances_name" {
  default     = "terraform_vm"
}

variable "admin" {
  description = "OS user"
  default     = "ubuntu"
}


#--------------------------------------------------------------------------------------
# VNic Configuration
#--------------------------------------------------------------------------------------
variable "private_ip" {
  default = "192.168.10.51"
}

variable "hostname" {
  description = "Hostname of instances"
  default     = "web-app-1.alluvium.com"
}


#--------------------------------------------------------------------------------------
# Compute Instance
#--------------------------------------------------------------------------------------
variable "instance_name" {
  default = "terraform-webapp"
}

variable "osdisk_size" {
  default = "30"
}

variable "vm_type" {   # gcloud compute machine-types list --filter="zone:us-east1-b and name:e2-micro"
  default = "e2-micro"
}