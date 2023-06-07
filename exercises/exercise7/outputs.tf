output "bitcoin_function_url" {
  value = module.lambda_function["bitcoin"].function_url
}

output "hello_function_url" {
  value = module.lambda_function["hello"].function_url
}

output "pi_function_url" {
  value = module.lambda_function["pi"].function_url
}

output "handler_url" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}
