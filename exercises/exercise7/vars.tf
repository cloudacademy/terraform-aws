variable "lambda_functions" {
  type = list(object({
    name          = string
    source_file   = string
    zip_file_name = string
    timeout       = number
    runtime       = string
  }))
  description = "list of lambda functions to create"
  default = [
    {
      name          = "bitcoin"
      source_file   = "./fns/bitcoin/code/lambda_function.py"
      zip_file_name = "./archive/fn.bitcoin.zip"
      timeout       = 60
      runtime       = "python3.9"
    },
    {
      name          = "hello"
      source_file   = "./fns/hello/code/lambda_function.py"
      zip_file_name = "./archive/fn.hello.zip"
      timeout       = 60
      runtime       = "python3.9"
    },
    {
      name          = "pi"
      source_file   = "./fns/pi/code/lambda_function.py"
      zip_file_name = "./archive/fn.pi.zip"
      timeout       = 60
      runtime       = "python3.9"
    }
  ]
}
