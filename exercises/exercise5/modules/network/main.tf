terraform {
  required_version = ">= 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
#tfsec:ignore:aws-ec2-no-public-ip-subnet
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "QA.Cloud.DevOps"
  cidr = var.cidr_block

  azs             = var.availability_zones
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Name = "QA.Cloud.DevOps"
    Demo = "Terraform"
  }
}
