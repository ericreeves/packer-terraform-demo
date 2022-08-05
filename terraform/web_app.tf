#
# EC2 Web Application
#
data "hcp_packer_iteration" "web" {
  bucket_name = "acme-webapp"
  channel     = "production"
}

data "hcp_packer_image" "acme_us_east_2" {
  bucket_name    = "acme-webapp"
  cloud_provider = "aws"
  iteration_id   = data.hcp_packer_iteration.web.ulid
  region         = "us-east-2"
}

resource "aws_instance" "acme" {
  ami                         = data.hcp_packer_image.acme_us_east_2.cloud_image_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.acme.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.acme.id
  vpc_security_group_ids      = [aws_security_group.acme.id]

  tags = {
    Name = "${var.prefix}-AcmeCo-Web-App"
  }
}

resource "aws_eip" "acme" {
  instance = aws_instance.acme.id
  vpc      = true
}

resource "aws_eip_association" "acme" {
  instance_id   = aws_instance.acme.id
  allocation_id = aws_eip.acme.id
}

resource "tls_private_key" "acme" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource "aws_key_pair" "acme" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.acme.public_key_openssh
}
