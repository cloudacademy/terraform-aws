output "function_url" {
  value = aws_lambda_function_url.lambda.function_url
}

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}
