module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "CloudAcademy"
  cidr = var.cidr_block

  azs             = var.availability_zones
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Name = "CloudAcademy"
    Demo = "Terraform"
  }
}