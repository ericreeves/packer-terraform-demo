#
# EC2 Web Application
#
data "hcp_packer_iteration" "ubuntu" {
  bucket_name = "packer-terraform-demo"
  channel     = "production"
}

data "hcp_packer_image" "ubuntu_us_east_2" {
  bucket_name    = "packer-terraform-demo"
  cloud_provider = "aws"
  iteration_id   = data.hcp_packer_iteration.ubuntu.ulid
  region         = "us-east-2"
}

resource "aws_instance" "hashicat" {
  ami                         = data.hcp_packer_image.ubuntu_us_east_2.cloud_image_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.hashicat.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.hashicat.id
  vpc_security_group_ids      = [aws_security_group.hashicat.id]

  tags = {
    Name = "${var.prefix}-HashiCat-Web-App"
  }
}

resource "aws_eip" "hashicat" {
  instance = aws_instance.hashicat.id
  vpc      = true
}

resource "aws_eip_association" "hashicat" {
  instance_id   = aws_instance.hashicat.id
  allocation_id = aws_eip.hashicat.id
}

resource "tls_private_key" "hashicat" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

resource "aws_key_pair" "hashicat" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.hashicat.public_key_openssh
}
