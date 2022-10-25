output "ubuntu_iteration" {
  value = data.hcp_packer_iteration.ubuntu
}

output "webapp_image" {
  value = data.hcp_packer_image.webapp_image
}

output "catapp_url" {
  value = "http://${aws_eip.acme.public_dns}"
}

output "catapp_ip" {
  value = "http://${aws_eip.acme.public_ip}"
}
