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
  
resource "aws_instance" "bastion" {
	ami                         = data.aws_ami.ubuntu.id
	instance_type               = var.instance_type
	key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  security_groups             = [var.sg_id]
  associate_public_ip_address = true

	tags = {
		Name = "Bastion"	
		Owner = "CloudAcademy"
	}
}  