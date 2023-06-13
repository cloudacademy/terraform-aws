terraform {
  required_version = ">= 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

//========================================

module "stocks_cicd" {
  source = "./modules/cicd"

  repo_name           = "stocks"
  repo_default_branch = "main"

  region                    = "us-west-2"
  build_timeout             = "5"
  build_compute_type        = "BUILD_GENERAL1_SMALL"
  build_image               = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  build_privileged_override = true
  buildspec_stocks_api      = "./stocks-api/buildspec.yml"
  buildspec_stocks_app      = "./stocks-app/buildspec.yml"
  buildspec_stocks_db       = "./stocks-db/buildspec.yml"
  force_artifact_destroy    = true
}

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
