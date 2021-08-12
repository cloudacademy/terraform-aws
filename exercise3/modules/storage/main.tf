data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  #Canonical
  owners = ["099720109477"] 
}

#====================================

resource "aws_instance" "mongo" {
	ami             = data.aws_ami.ubuntu.id
	instance_type   = var.instance_type
	key_name        = var.key_name
  subnet_id       = var.subnet_id
  security_groups = [var.sg_id]
	
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

  user_data = filebase64("${path.module}/install.sh")

	tags = {
		Name = "Mongo"	
		Owner = "CloudAcademy"
	}
}  