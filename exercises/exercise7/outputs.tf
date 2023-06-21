output "bitcoin_function_url" {
  value = module.lambda_function["bitcoin"].function_url
}

output "bitcoin_api_gateway_url" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/bitcoin"
}

output "hello_function_url" {
  value = module.lambda_function["hello"].function_url
}

output "hello_api_gateway_url" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/hello"
}

output "pi_function_url" {
  value = module.lambda_function["pi"].function_url
}

output "pi_api_gateway_url" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/pi"
}
