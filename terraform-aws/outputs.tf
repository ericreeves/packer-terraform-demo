output "ubuntu_iteration" {
  value = data.hcp_packer_iteration.ubuntu
}

output "ubuntu_us_east_2" {
  value = data.hcp_packer_image.ubuntu_us_east_2
}

output "catapp_url" {
  value = "http://${aws_eip.hashicat.public_dns}"
}

output "catapp_ip" {
  value = "http://${aws_eip.hashicat.public_ip}"
}
