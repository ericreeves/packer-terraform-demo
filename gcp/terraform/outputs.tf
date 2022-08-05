output "acme-webapp-ip" {
  value = google_compute_instance.terraform_instance.network_interface.0.access_config.0.nat_ip
}

output "acme-webapp-url" {
  value = "http://${google_compute_instance.terraform_instance.network_interface.0.access_config.0.nat_ip}"
}