resource "aws_instance" "bastion" {
  ami                         = "ami-00712dae9a53f8c15"
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  associate_public_ip_address = true

  tags = {
    Name  = "Bastion"
    Owner = "HOFFSTER"
  }
}
