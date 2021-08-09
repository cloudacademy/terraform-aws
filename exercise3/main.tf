terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.51.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

module "network" {
  source = "./modules/network"
}

module "security" {
  source = "./modules/security"

  vpc_id = module.network.vpc_id
  workstation_ip = var.workstation_ip

  depends_on = [
    module.network
  ]
}

module "bastion" {
  source = "./modules/bastion"

  instance_type = "t3.micro"
  key_name = var.key_name
  subnet_id = module.network.subnet1_id
  sg_id = module.security.bastion_sg_id

  depends_on = [
    module.network,
    module.security
  ]
}

module "storage" {
  source = "./modules/storage"

  instance_type = "t3.micro"
  key_name = var.key_name
  subnet_id = module.network.subnet3_id
  sg_id = module.security.mongodb_sg_id

  depends_on = [
    module.network,
    module.security
  ]
}

module "application" {
  source = "./modules/application"

  instance_type = "t3.micro"
  key_name = var.key_name
  vpc_id = module.network.vpc_id
  subnet1_id = module.network.subnet1_id
  subnet2_id = module.network.subnet2_id
  subnet3_id = module.network.subnet3_id
  subnet4_id = module.network.subnet4_id
  webserver_sg_id = module.security.webserver_sg_id
  alb_sg_id = module.security.alb_sg_id
  mongodb_ip = module.storage.private_ip

  depends_on = [
    module.network,
    module.security,
    module.storage
  ]
}

