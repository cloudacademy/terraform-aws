output "clone_repo_https" {
  value = aws_codecommit_repository.repo.clone_url_http
}

output "clone_repo_ssh" {
  value = aws_codecommit_repository.repo.clone_url_ssh
}

output "artifact_bucket" {
  value = aws_s3_bucket.build_artifact_bucket.id
}

output "codepipeline_role" {
  value = aws_iam_role.codepipeline_role.arn
}

output "codepipeline_role_name" {
  value = aws_iam_role.codepipeline_role.id
}

output "codebuild_role" {
  value = aws_iam_role.codebuild_assume_role.arn
}

output "codebuild_role_name" {
  value = aws_iam_role.codebuild_assume_role.id
}

