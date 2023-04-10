terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "null" {
  # Configuration options
}

#====================================

module "network" {
  source = "./modules/network"

  availability_zones = var.availability_zones
  cidr_block         = var.cidr_block
}

#====================================

module "security" {
  source = "./modules/security"

  vpc_id         = module.network.vpc_id
  workstation_ip = var.workstation_ip

  depends_on = [
    module.network
  ]
}

#====================================

module "bastion" {
  source = "./modules/bastion"

  instance_type = var.bastion_instance_type
  key_name      = var.key_name
  subnet_id     = module.network.public_subnets[0]
  sg_id         = module.security.bastion_sg_id

  depends_on = [
    module.network,
    module.security
  ]
}

#====================================

module "storage" {
  source = "./modules/storage"

  instance_type = var.db_instance_type
  key_name      = var.key_name
  subnet_id     = module.network.private_subnets[0]
  sg_id         = module.security.mongodb_sg_id

  depends_on = [
    module.network,
    module.security
  ]
}

#====================================

module "application" {
  source = "./modules/application"

  instance_type   = var.app_instance_type
  key_name        = var.key_name
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  webserver_sg_id = module.security.application_sg_id
  alb_sg_id       = module.security.alb_sg_id

  depends_on = [
    module.network,
    module.security,
    module.storage
  ]
}

#====================================

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}/ansible"
    command     = <<EOT
      sleep 120 #time to allow VMs to come online and stabilize
      mkdir -p ./logs

      sed \
      -e 's/BASTION_IP/${module.bastion.public_ip}/g' \
      -e 's/WEB_IPS/${join("\\n", module.application.private_ips)}/g' \
      -e 's/MONGO_IP/${module.storage.private_ip}/g' \
      ./templates/hosts > hosts

      sed \
      -e 's/BASTION_IP/${module.bastion.public_ip}/g' \
      -e 's/SSH_KEY_NAME/${var.key_name}/g' \
      ./templates/ssh_config > ssh_config

      #required for macos only
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

      #ANSIBLE
      ansible-playbook -v \
      -i hosts \
      --extra-vars "ALB_DNS=${module.application.dns_name}" \
      --extra-vars "MONGODB_PRIVATEIP=${module.storage.private_ip}" \
      ./playbooks/master.yml
      echo finished!
    EOT
  }

  depends_on = [
    module.bastion,
    module.application
  ]
}
