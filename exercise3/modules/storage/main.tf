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

  owners = ["099720109477"] # Canonical
}
  
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
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
    */

    user_data = filebase64("${path.module}/install.sh")

	tags = {
		Name = "Mongo"	
		Owner = "CloudAcademy"
	}
}  