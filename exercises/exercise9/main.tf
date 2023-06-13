terraform {
  required_version = ">= 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}

//========================================

locals {
  repo_name = "stocks"
  region    = "us-west-2"
}

//========================================

provider "aws" {
  region = local.region
}

//========================================

resource "aws_ecr_repository" "stocks-api" {
  name         = "stocks-api"
  force_delete = true
}

resource "aws_ecr_repository" "stocks-app" {
  name         = "stocks-app"
  force_delete = true
}

resource "aws_ecr_repository" "stocks-db" {
  name         = "stocks-db"
  force_delete = true
}

//========================================

module "stocks_cicd" {
  source = "./modules/cicd"

  repo_name           = local.repo_name
  repo_default_branch = "main"

  region                    = local.region
  build_timeout             = "5"
  build_compute_type        = "BUILD_GENERAL1_SMALL"
  build_image               = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  build_privileged_override = true
  buildspec_stocks_api      = "./stocks-api/buildspec.yml"
  buildspec_stocks_app      = "./stocks-app/buildspec.yml"
  buildspec_stocks_db       = "./stocks-db/buildspec.yml"
  force_artifact_destroy    = true
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "serverless-codebuild-automation-policy"
  role = module.stocks_cicd.codebuild_role_name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
POLICY
}

//========================================

resource "null_resource" "stocks_source_code" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    command     = <<EOT
      echo loading source code...
      cd ./stocks
      git init
      git remote add -f ${local.repo_name} https://git-codecommit.${local.region}.amazonaws.com/v1/repos/${local.repo_name}
      git checkout -b main
      git add .
      git commit -m "initial commit"
      git push --set-upstream ${local.repo_name} main
    EOT
  }

  depends_on = [
    module.stocks_cicd
  ]
}
