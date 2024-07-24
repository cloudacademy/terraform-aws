terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

module "lambda_function" {
  source   = "./modules/lambda_function"
  for_each = { for index, fn in var.lambda_functions : fn.name => fn }

  name            = each.value.name
  lambda_role_arn = aws_iam_role.lambda_role.arn
  source_file     = "${path.root}/${each.value.source_file}"
  zip_file_name   = each.value.zip_file_name
  timeout         = each.value.timeout
  runtime         = each.value.runtime
}
