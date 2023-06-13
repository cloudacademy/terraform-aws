terraform {
  required_version = ">= 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  region      = "us-east-1"
  environment = "prod"

  domain_name         = "demo.cloudacademydevops.internal"
  domain_netbios_name = "CADEVOPS"
  domain_computer_ou  = "ou=demo,dc=cloudacademydevops,dc=internal"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

provider "aws" {
  region = local.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "CloudAcademy"
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Name = "CloudAcademy"
    Demo = "AD and Windows Server Domain Join"
    Env  = local.environment
  }
}

module "ad" {
  source = "./modules/ad"

  domain_name = local.domain_name
  short_name  = local.domain_netbios_name
  computer_ou = local.domain_computer_ou

  edition        = "Standard"
  admin_password = "0potC2Xk2X74%#!t"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnets
}

//========================================

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_iam_role" {
  name               = "ec2-iam-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_iam_role.name
}

resource "aws_iam_policy_attachment" "ec2_attach1" {
  name       = "ec2-iam-attachment"
  roles      = [aws_iam_role.ec2_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ec2_attach2" {
  name       = "ec2-iam-attachment"
  roles      = [aws_iam_role.ec2_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy" "secret_manager_ec2_policy" {
  name        = "secret-manager-ec2-policy"
  description = "Secret Manager EC2 policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "api_secret_manager_ec2_attach" {
  name       = "secret-manager-ec2-attachment"
  roles      = [aws_iam_role.ec2_iam_role.id]
  policy_arn = aws_iam_policy.secret_manager_ec2_policy.arn
}

#========================================

resource "aws_security_group" "windows-sg" {
  name        = "windows-sg"
  description = "Allow incoming connections"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "windows-sg"
    Env  = local.environment
  }
}

data "template_file" "server" {
  template = file("${path.root}/join.ps1")
  vars = {
    ad_secret_id = "AD/ServiceAccounts/DomainJoin"
    ad_domain    = local.domain_name
  }
}

data "aws_ami" "windows-2022" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "windows-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

resource "aws_instance" "server" {
  ami                         = data.aws_ami.windows-2022.id
  instance_type               = var.windows_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.windows-sg.id]
  source_dest_check           = false
  key_name                    = aws_key_pair.key_pair.key_name
  user_data                   = data.template_file.server.rendered
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.id

  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_data_volume_type
    delete_on_termination = true
  }
  tags = {
    Name = "cloudacademydemo-vm1"
    Env  = local.environment
  }
  volume_tags = {
    Name = "cloudacademydemo-vol1"
    Env  = local.environment
  }

  depends_on = [
    module.ad
  ]
}
