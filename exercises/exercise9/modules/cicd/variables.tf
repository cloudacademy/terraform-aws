variable "region" {
  type        = string
  description = "region to deploy into"
}

variable "repo_name" {
  type        = string
  description = "CodeCommit repo name"
}

variable "repo_default_branch" {
  type        = string
  description = "default repository branch name"
  default     = "main"
}

variable "force_artifact_destroy" {
  type        = bool
  description = "Force the removal of the artifact S3 bucket on destroy"
  default     = false
}

variable "build_timeout" {
  type        = string
  description = "The time to wait for a CodeBuild to complete before timing out in minutes (default: 5)"
  default     = "5"
}

variable "build_compute_type" {
  type        = string
  description = "build instance type for CodeBuild"
}

variable "build_image" {
  type        = string
  description = "build image for CodeBuild to use"
}

variable "build_privileged_override" {
  type        = bool
  description = "build privileged override - relevant to building Docker images"
  default     = false
}

variable "buildspec_stocks_api" {
  type        = string
  description = "buildspec to create stocks-api docker image"
}

variable "buildspec_stocks_app" {
  type        = string
  description = "buildspec to create stocks-app docker image"
}

variable "buildspec_stocks_db" {
  type        = string
  description = "buildspec to create stocks-db docker image"
}
