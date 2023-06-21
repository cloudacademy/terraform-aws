data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.source_file
  output_path = var.zip_file_name
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.name
  filename         = var.zip_file_name
  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = var.lambda_role_arn
  runtime          = var.runtime
  handler          = "lambda_function.lambda_handler"
  timeout          = var.timeout
}

resource "aws_lambda_function_url" "lambda" {
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
