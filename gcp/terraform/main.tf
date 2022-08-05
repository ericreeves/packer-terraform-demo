#---------------------------------------------------------------------------------------
# Required Providers
#---------------------------------------------------------------------------------------
provider "hcp" {}

provider "google" {
  # credentials = file(var.gcp_credentials)
  project     = var.gcp_project
  region      = var.region
  zone        = var.zone
}