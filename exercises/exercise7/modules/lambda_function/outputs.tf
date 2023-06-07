output "function_url" {
  value = aws_lambda_function_url.bitcoin.function_url
}

output "invoke_arn" {
  value = aws_lambda_function.bitcoin.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.bitcoin.function_name
}
