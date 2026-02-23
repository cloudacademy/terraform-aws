terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {}

locals {
  name             = "QA-Cloud-DevOps"
  eks_cluster_name = "${local.name}-EKS-Cluster"
  environment      = "Demo"
  k8s_version      = "1.35"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

# NETWORK
#====================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  manage_default_network_acl    = true
  manage_default_route_table    = true
  manage_default_security_group = true

  default_network_acl_tags = {
    Name = "${local.name}-default"
  }

  default_route_table_tags = {
    Name = "${local.name}-default"
  }

  default_security_group_tags = {
    Name = "${local.name}-default"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}

# EKS CLUSTER
#====================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.15"

  name = local.eks_cluster_name

  kubernetes_version = local.k8s_version

  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  addons = {
    vpc-cni = {
      most_recent    = true
      before_compute = true # must be installed before nodes join
    }
    kube-proxy = {
      most_recent    = true
      before_compute = true
    }
    coredns = {
      most_recent = true
      # before_compute = false (default) - requires nodes to be running
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      use_custom_launch_template = false

      instance_types = ["m5.large"]
      # capacity_type  = "SPOT" # useful for demos and dev purposes
      capacity_type = "ON_DEMAND"

      disk_size = 20 #Minimum required disk size for AL2023_x86_64_STANDARD ami-type is 20

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}

# NGINX INGRESS CONTROLLER
#====================================

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "us-west-2"]
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name = "nginx-ingress"

  repository       = "https://helm.nginx.com/stable"
  chart            = "nginx-ingress"
  namespace        = "nginx-ingress"
  create_namespace = true

  set = [
    {
      name  = "service.type"
      value = "ClusterIP"
    },
    {
      name  = "controller.service.name"
      value = "nginx-ingress-controller"
    }
  ]
}

# K8s APP DEPLOYMENT
#====================================

resource "terraform_data" "deploy_app" {
  triggers_replace = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    command     = <<EOT
      echo deploying app...
      ./k8s/app.install.sh ${local.eks_cluster_name}
    EOT
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}

# OUTPUTS
#====================================

output "token" {
  value     = data.aws_eks_cluster_auth.cluster_auth.token
  sensitive = true
}
