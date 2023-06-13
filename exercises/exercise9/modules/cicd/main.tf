terraform {
  required_version = ">= 1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}

//========================================

resource "aws_codecommit_repository" "repo" {
  repository_name = var.repo_name
  description     = var.repo_name
  default_branch  = var.repo_default_branch
}

resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = "ca-cicd-artifacts"
  force_destroy = var.force_artifact_destroy
}

resource "aws_kms_key" "artifact_encryption_key" {
  description             = "cloudacademy cicd artifact encryption key"
  deletion_window_in_days = 10
}

// CODEBUILD IAM POLICIES
//========================================

data "template_file" "codebuild_assume_role_policy_template" {
  template = file("${path.module}/iam/codebuild/assume_role_policy.tpl")
}

data "template_file" "codebuild_policy_template" {
  template = file("${path.module}/iam/codebuild/permissions_policy.tpl")
  vars = {
    artifact_bucket              = aws_s3_bucket.build_artifact_bucket.arn
    aws_kms_key                  = aws_kms_key.artifact_encryption_key.arn
    codebuild_project_stocks_api = aws_codebuild_project.stocks_api.id
    codebuild_project_stocks_app = aws_codebuild_project.stocks_app.id
  }
}

resource "aws_iam_role" "codebuild_assume_role" {
  name               = "cloudacademy-codebuild-role"
  assume_role_policy = data.template_file.codebuild_assume_role_policy_template.rendered
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "cloudacademy-codebuild-policy"
  role = aws_iam_role.codebuild_assume_role.id

  policy = data.template_file.codebuild_policy_template.rendered
}

// CODEPIPELINE IAM POLICIES
//========================================

data "template_file" "codepipeline_assume_role_policy_template" {
  template = file("${path.module}/iam/codepipeline/assume_role_policy.tpl")
}

data "template_file" "codepipeline_policy_template" {
  template = file("${path.module}/iam/codepipeline/permissions_policy.tpl")
  vars = {
    aws_kms_key     = aws_kms_key.artifact_encryption_key.arn
    artifact_bucket = aws_s3_bucket.build_artifact_bucket.arn
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "cloudacademy-codepipeline-role"
  assume_role_policy = data.template_file.codepipeline_assume_role_policy_template.rendered
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "cloudacademy-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = data.template_file.codepipeline_policy_template.rendered
}

// CODEBUILD PROJECTS
//========================================

resource "aws_codebuild_project" "stocks_api" {
  name           = "stocks-api"
  description    = "Stocks API"
  service_role   = aws_iam_role.codebuild_assume_role.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.build_privileged_override
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_stocks_api
  }
}

resource "aws_codebuild_project" "stocks_app" {
  name           = "stocks-app"
  description    = "Stocks App"
  service_role   = aws_iam_role.codebuild_assume_role.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.build_privileged_override
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_stocks_app
  }
}

resource "aws_codebuild_project" "stocks_db" {
  name           = "stocks-db"
  description    = "Stocks DB"
  service_role   = aws_iam_role.codebuild_assume_role.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.build_privileged_override
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_stocks_db
  }
}

// CODEPIPELINE
//========================================

resource "aws_codepipeline" "codepipeline" {
  name     = var.repo_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.build_artifact_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact_encryption_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = var.repo_name
        BranchName     = var.repo_default_branch
      }
    }
  }

  stage {
    name = "BuildStocksApp"

    action {
      name             = "StocksAPI"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["stocks-api"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.stocks_api.name
      }
    }

    action {
      name             = "StocksApp"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["stocks-app"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.stocks_app.name
      }
    }

    action {
      name             = "StocksDB"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["stocks-db"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.stocks_db.name
      }
    }
  }
}
