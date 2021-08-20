resource "aws_instance" "bastion" {
  ami                         = "ami-02868af3c3df4b3aa"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  security_groups             = [var.sg_id]
  associate_public_ip_address = true

  tags = {
    Name  = "Bastion"
    Owner = "CloudAcademy"
  }
}  