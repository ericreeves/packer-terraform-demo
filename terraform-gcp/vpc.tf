#---------------------------------------------------------------------------------------
# Service Account (optional)
#---------------------------------------------------------------------------------------
# Note: The user running terraform needs to have the IAM Admin role assigned to them before you can do this.
# resource "google_service_account" "instance_admin" { 
#  account_id   = "instance-admin"
#  display_name = "instance s-account"
#  }
# resource "google_project_iam_binding" "instance_sa_iam" {
#  project = data.google_client_config.current.project # < PROJECT ID>
#  role    = "roles/compute.instanceAdmin.v1"
#  members = [
#    "serviceAccount:${google_service_account.instance_admin.email}"
#  ]

#---------------------------------------------------------------------------------------
# VPC
#---------------------------------------------------------------------------------------
resource "google_compute_network" "terraform_vpc" {
  project                 = data.google_client_config.current.project
  name                    = "terraform-vpc"
  auto_create_subnetworks = false
}


#---------------------------------------------------------------------------------------
# Subnet
#---------------------------------------------------------------------------------------
resource "google_compute_subnetwork" "terraform_sub" {
  name                     = var.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.terraform_vpc.name
  description              = "Terraform Demo Subnet"
  private_ip_google_access = "true"

  # secondary_ip_range {
  #   range_name    = "subnet-01-secondary-01"
  #   ip_cidr_range = var.secondary_cidr
  # }
}


#---------------------------------------------------------------------------------------
# Firewall
#---------------------------------------------------------------------------------------
resource "google_compute_firewall" "web-server" {
  project     = data.google_client_config.current.project # you can Replace this with your project ID in quotes var.project_id
  name        = "allow-http-rule"
  network     = google_compute_network.terraform_vpc.name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["80", "22", "443", "3389"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  timeouts {}
}