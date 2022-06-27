output "gcp-project" {
  value = data.google_client_config.current.project
}

output "acme-webapp-ip" {
  value = google_compute_instance.terra_instance.network_interface.0.access_config.0.nat_ip
}

output "acme-webapp-url" {
  value = "http://${google_compute_instance.terra_instance.network_interface.0.access_config.0.nat_ip}"
}

output "ubuntu_iteration" {
  value = data.hcp_packer_iteration.ubuntu
}

output "ubuntu_gcp" {
  value = data.hcp_packer_image.ubuntu_us_east_2
}
