output "repo_url" {
  value = module.stocks_cicd.clone_repo_https
}

output "codepipeline_role" {
  value = module.stocks_cicd.codepipeline_role
}

output "codebuild_role" {
  value = module.stocks_cicd.codebuild_role
}

output "ecr_stocks_api_url" {
  value = aws_ecr_repository.stocks-api.repository_url
}

output "ecr_stocks_app_url" {
  value = aws_ecr_repository.stocks-app.repository_url
}

output "ecr_stocks_db_url" {
  value = aws_ecr_repository.stocks-db.repository_url
}
