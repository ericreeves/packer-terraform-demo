output "webapp_url" {
  value = "http://${aws_eip.acme.public_dns}"
}

output "webapp_ip" {
  value = "http://${aws_eip.acme.public_ip}"
}
