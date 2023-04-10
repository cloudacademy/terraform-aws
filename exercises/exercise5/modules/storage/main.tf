terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

#tfsec:ignore:aws-ec2-enforce-http-token-imds
resource "aws_instance" "mongo" {
  ami                    = "ami-02868af3c3df4b3aa"
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  root_block_device {
    volume_size = 10
    encrypted   = true
  }

  /*
  user_data = << EOF
  #! /bin/bash
  sudo apt-get update
  sudo apt-get install -y nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
  echo "<h1>CloudAcademy 2021</h1>" | sudo tee /var/www/html/index.html
	EOF
  */

  #user_data = filebase64("${path.module}/install.sh")

  tags = {
    Name  = "Mongo"
    Owner = "CloudAcademy"
  }
}
