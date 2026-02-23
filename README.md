![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/cloudacademy/terraform-aws)

# CloudAcademy Terraform 1.x AWS Course

This repo contains example Terraform projects for building AWS infrastructure. The example Terraform projects are catalogued into a set of AWS exercises, graduating in complexity as you work through them.

## AWS Exercises

The exercises directory contains a set of different AWS infrastructure provisioning exercises.

### Exercise 1

Create a simple AWS VPC spanning 2 AZs. Public subnets will be created, together with an internet gateway, and single route table. A t3.micro instance will be deployed and installed with Nginx for web serving. Security groups will be created and deployed to secure all network traffic between the various components.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise1

![AWS Architecture](./doc/AWS-VPC-Nginx.png)

#### Project Structure

```
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### TF Variable Notes

> **Note**: SSH access is automatically restricted to your current machine's public IP address, dynamically detected at `terraform plan`/`apply` time using the `hashicorp/http` provider and `http://checkip.amazonaws.com`. No `workstation_ip` variable is required.

- `key_name`: The Terraform variable `key_name` represents the AWS SSH Keypair name that will be used to allow SSH access to the instance(s) provisioned by Terraform. You will need to create your own SSH Keypair (typically done within the AWS EC2 console) ahead of time.
  - The required Terraform `key_name` variable can be established by prefixing the variable name with `TF_VAR_` and setting it as an environment variable within your shell:

  - **Linux**: `export TF_VAR_key_name=your_ssh_key_name`

  - **Windows**: `set TF_VAR_key_name=your_ssh_key_name`

- Terraform environment variables are documented here:
  [https://www.terraform.io/cli/config/environment-variables](https://www.terraform.io/cli/config/environment-variables)

### Exercise 2

Create an advanced AWS VPC spanning 2 AZs with both public and private subnets. An internet gateway and NAT gateway will be deployed into it. Public and private route tables will be established. An application load balancer (ALB) will be installed which will load balance traffic across an auto scaling group (ASG) of Nginx web servers. Security groups will be created and deployed to secure all network traffic between the various components.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise2

![AWS Architecture](./doc/AWS-VPC-ASG-Nginx.png)

#### Project Structure

```
├── ec2.userdata
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### TF Variable Notes

> **Note**: SSH access is automatically restricted to your current machine's public IP address, dynamically detected at `terraform plan`/`apply` time using the `hashicorp/http` provider and `http://checkip.amazonaws.com`. No `workstation_ip` variable is required.

- `key_name`: The Terraform variable `key_name` represents the AWS SSH Keypair name that will be used to allow SSH access to the instance(s) provisioned by Terraform. You will need to create your own SSH Keypair (typically done within the AWS EC2 console) ahead of time.
  - The required Terraform `key_name` variable can be established by prefixing the variable name with `TF_VAR_` and setting it as an environment variable within your shell:

  - **Linux**: `export TF_VAR_key_name=your_ssh_key_name`

  - **Windows**: `set TF_VAR_key_name=your_ssh_key_name`

- Terraform environment variables are documented here:
  [https://www.terraform.io/cli/config/environment-variables](https://www.terraform.io/cli/config/environment-variables)

### Exercise 3

Same AWS architecture as used in Exercise 2. This exercise demonstrates a different Terraform technique, using the Terraform "count" meta argument, for configuring the public and private subnets as well as their respective route tables.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise3

![AWS Architecture](./doc/AWS-VPC-ASG-Nginx.png)

#### Project Structure

```
├── ec2.userdata
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### TF Variable Notes

> **Note**: SSH access is automatically restricted to your current machine's public IP address, dynamically detected at `terraform plan`/`apply` time using the `hashicorp/http` provider and `http://checkip.amazonaws.com`. No `workstation_ip` variable is required.

- `key_name`: The Terraform variable `key_name` represents the AWS SSH Keypair name that will be used to allow SSH access to the instance(s) provisioned by Terraform. You will need to create your own SSH Keypair (typically done within the AWS EC2 console) ahead of time.
  - The required Terraform `key_name` variable can be established by prefixing the variable name with `TF_VAR_` and setting it as an environment variable within your shell:

  - **Linux**: `export TF_VAR_key_name=your_ssh_key_name`

  - **Windows**: `set TF_VAR_key_name=your_ssh_key_name`

- Terraform environment variables are documented here:
  [https://www.terraform.io/cli/config/environment-variables](https://www.terraform.io/cli/config/environment-variables)

### Exercise 4

Create an advanced AWS VPC to host a fully functioning cloud native application.

![Cloud Native Application](/doc/voteapp.png)

The VPC will span 2 AZs, and have both public and private subnets. An internet gateway and NAT gateway will be deployed into it. Public and private route tables will be established. An application load balancer (ALB) will be installed which will load balance traffic across an auto scaling group (ASG) of Nginx web servers installed with the cloud native application frontend and API. A database instance running MongoDB will be installed in the private zone. Security groups will be created and deployed to secure all network traffic between the various components.

For demonstration purposes only - both the frontend and the API will be deployed to the same set of ASG instances - to reduce running costs.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise4

![AWS Architecture](/doc/AWS-VPC-FullApp.png)

The auto scaling web application layer bootstraps itself with both the [Frontend](https://github.com/cloudacademy/voteapp-frontend-react-2023) and [API](https://github.com/cloudacademy/voteapp-api-go) components by pulling down their **latest** respective releases from the following repos:

- Frontend: https://github.com/cloudacademy/voteapp-frontend-react-2023/releases/latest

- API: https://github.com/cloudacademy/voteapp-api-go/releases/latest

The bootstrapping process for the [Frontend](https://github.com/cloudacademy/voteapp-frontend-react-2023) and [API](https://github.com/cloudacademy/voteapp-api-go) components is codified within a `template_cloudinit_config` block located in the application module's [main.tf](./modules/application/main.tf) file:

```terraform
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  #userdata
  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #! /bin/bash
    apt-get -y update
    apt-get -y install nginx
    apt-get -y install jq

    ALB_DNS=${aws_lb.alb1.dns_name}
    MONGODB_PRIVATEIP=${var.mongodb_ip}

    mkdir -p /tmp/cloudacademy-app
    cd /tmp/cloudacademy-app

    echo ===========================
    echo FRONTEND - download latest release and install...
    mkdir -p ./voteapp-frontend-react-2023
    pushd ./voteapp-frontend-react-2023
    curl -sL https://api.github.com/repos/cloudacademy/voteapp-frontend-react-2023/releases/latest | jq -r '.assets[0].browser_download_url' | xargs curl -OL
    INSTALL_FILENAME=$(curl -sL https://api.github.com/repos/cloudacademy/voteapp-frontend-react-2023/releases/latest | jq -r '.assets[0].name')
    tar -xvzf $INSTALL_FILENAME
    rm -rf /var/www/html
    cp -R build /var/www/html
    cat > /var/www/html/env-config.js << EOFF
    window._env_ = {REACT_APP_APIHOSTPORT: "$ALB_DNS"}
    EOFF
    popd

    echo ===========================
    echo API - download latest release, install, and start...
    mkdir -p ./voteapp-api-go
    pushd ./voteapp-api-go
    curl -sL https://api.github.com/repos/cloudacademy/voteapp-api-go/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) | .browser_download_url' | xargs curl -OL
    INSTALL_FILENAME=$(curl -sL https://api.github.com/repos/cloudacademy/voteapp-api-go/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) | .name')
    tar -xvzf $INSTALL_FILENAME
    #start the API up...
    MONGO_CONN_STR=mongodb://$MONGODB_PRIVATEIP:27017/langdb ./api &
    popd

    systemctl restart nginx
    systemctl status nginx
    echo fin v1.00!

    EOF
  }
}
```

#### ALB Target Group Configuration

The ALB will configured with a single listener (port 80). 2 target groups will be established. The frontend target group points to the Nginx web server (port 80). The API target group points to the custom API service (port 8080).

![AWS Architecture](/doc/AWS-VPC-FullApp-TargetGrps.png)

#### Project Structure

```
├── main.tf
├── modules
│   ├── application
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   ├── bastion
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   ├── security
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   └── storage
│       ├── install.sh
│       ├── main.tf
│       ├── outputs.tf
│       └── vars.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### TF Variable Notes

> **Note**: SSH access is automatically restricted to your current machine's public IP address, dynamically detected at `terraform plan`/`apply` time using the `hashicorp/http` provider and `http://checkip.amazonaws.com`. No `workstation_ip` variable is required.

- `key_name`: The Terraform variable `key_name` represents the AWS SSH Keypair name that will be used to allow SSH access to the instance(s) provisioned by Terraform. You will need to create your own SSH Keypair (typically done within the AWS EC2 console) ahead of time.
  - The required Terraform `key_name` variable can be established by prefixing the variable name with `TF_VAR_` and setting it as an environment variable within your shell:

  - **Linux**: `export TF_VAR_key_name=your_ssh_key_name`

  - **Windows**: `set TF_VAR_key_name=your_ssh_key_name`

- Terraform environment variables are documented here:
  [https://www.terraform.io/cli/config/environment-variables](https://www.terraform.io/cli/config/environment-variables)

### Exercise 5

Refactoring of the Cloud Native Application (excercise 4) to use [Ansible](https://www.ansible.com/) for configuration management.

![Cloud Native Application](/doc/voteapp.png)

The VPC will span 2 AZs, and have both public and private subnets. An internet gateway and NAT gateway will be deployed into it. Public and private route tables will be established. An application load balancer (ALB) will be installed which will load balance traffic across an auto scaling group (ASG) of Nginx web servers installed with the cloud native application frontend and API. A database instance running MongoDB will be installed in the private zone. Security groups will be created and deployed to secure all network traffic between the various components.

For demonstration purposes only - both the frontend and the API will be deployed to the same set of ASG instances - to reduce running costs.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise5

![AWS Architecture](/doc/AWS-VPC-FullApp.png)

The auto scaling web application layer bootstraps itself with both the [Frontend](https://github.com/cloudacademy/voteapp-frontend-react-2023) and [API](https://github.com/cloudacademy/voteapp-api-go) components by pulling down their **latest** respective releases from the following repos:

- Frontend: https://github.com/cloudacademy/voteapp-frontend-react-2023/releases/latest

- API: https://github.com/cloudacademy/voteapp-api-go/releases/latest

The bootstrapping process for the [Frontend](https://github.com/cloudacademy/voteapp-frontend-react-2023) and [API](https://github.com/cloudacademy/voteapp-api-go) components is now performed by Ansible. An Ansible playbook is executed from within the root [main.tf](.exercises/exercise5/main.tf) file:

```terraform
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}/ansible"
    command     = <<EOT
      sleep 120 #time to allow VMs to come online and stabilize
      mkdir -p ./logs

      sed \
      -e 's/BASTION_IP/${module.bastion.public_ip}/g' \
      -e 's/WEB_IPS/${join("\\n", module.application.private_ips)}/g' \
      -e 's/MONGO_IP/${module.storage.private_ip}/g' \
      ./templates/hosts > hosts

      sed \
      -e 's/BASTION_IP/${module.bastion.public_ip}/g' \
      -e 's/SSH_KEY_NAME/${var.key_name}/g' \
      ./templates/ssh_config > ssh_config

      #required for macos only
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

      #ANSIBLE
      ansible-playbook -v \
      -i hosts \
      --extra-vars "ALB_DNS=${module.application.dns_name}" \
      --extra-vars "MONGODB_PRIVATEIP=${module.storage.private_ip}" \
      ./playbooks/master.yml
      echo finished!
    EOT
  }

  depends_on = [
    module.bastion,
    module.application
  ]
}
```

#### ALB Target Group Configuration

The ALB will configured with a single listener (port 80). 2 target groups will be established. The frontend target group points to the Nginx web server (port 80). The API target group points to the custom API service (port 8080).

![AWS Architecture](/doc/AWS-VPC-FullApp-TargetGrps.png)

#### Project Structure

```
├── main.tf
├── ansible
│   ├── ansible.cfg
│   ├── logs
│   │   └── ansible.log
│   ├── playbooks
│   │   ├── database.yml
│   │   ├── deployapp.yml
│   │   ├── files
│   │   │   ├── api.sh
│   │   │   ├── db.sh
│   │   │   └── frontend.sh
│   │   └── master.yml
│   └── templates
│       ├── hosts
│       └── ssh_config
├── modules
│   ├── application
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   ├── bastion
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   ├── security
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── vars.tf
│   └── storage
│       ├── install.sh
│       ├── main.tf
│       ├── outputs.tf
│       └── vars.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### TF Variable Notes

> **Note**: SSH access is automatically restricted to your current machine's public IP address, dynamically detected at `terraform plan`/`apply` time using the `hashicorp/http` provider and `http://checkip.amazonaws.com`. No `workstation_ip` variable is required.

- `key_name`: The Terraform variable `key_name` represents the AWS SSH Keypair name that will be used to allow SSH access to the instance(s) provisioned by Terraform. You will need to create your own SSH Keypair (typically done within the AWS EC2 console) ahead of time.
  - The required Terraform `key_name` variable can be established by prefixing the variable name with `TF_VAR_` and setting it as an environment variable within your shell:

  - **Linux**: `export TF_VAR_key_name=your_ssh_key_name`

  - **Windows**: `set TF_VAR_key_name=your_ssh_key_name`

- Terraform environment variables are documented here:
  [https://www.terraform.io/cli/config/environment-variables](https://www.terraform.io/cli/config/environment-variables)

### Exercise 6

Launch an EKS cluster and deploy a pre-built cloud native web app.

![Stocks App](/doc/stocks.png)

The following EKS architecture will be provisioned using Terraform:

![EKS Cloud Native Application](/doc/eks.png)

The cloud native web app that gets deployed is based on the following codebase:

- https://github.com/cloudacademy/stocks-app
- https://github.com/cloudacademy/stocks-api

The following public AWS **modules** are used to launch the EKS cluster:

- [VPC](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [EKS](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

Additionally, the following **providers** are utilised:

- [hashicorp/helm](https://registry.terraform.io/providers/hashicorp/helm/latest)
- [hashicorp/null](https://registry.terraform.io/providers/hashicorp/null/latest)

The EKS cluster will be provisioned with 2 worker nodes based on m5.large **spot** instances. This configuration is suitable for the demonstration purposes of this exercise. Production environments are likely more suited to **on-demand always on** instances.

The cloud native web app deployed is configured within the `./k8s` directory, and is installed automatically using the following null resource configuration:

```terraform
resource "null_resource" "deploy_app" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    command     = <<EOT
      echo deploying app...
      ./k8s/app.install.sh
    EOT
  }

  depends_on = [
    helm_release.nginx_ingress
  ]
}
```

The Helm provider is used to automatically install the Nginx Ingress Controller at provisioning time:

```terraform
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "us-west-2"]
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name = "nginx-ingress"

  repository       = "https://helm.nginx.com/stable"
  chart            = "nginx-ingress"
  namespace        = "nginx-ingress"
  create_namespace = true

  set = [
    {
      name  = "service.type"
      value = "ClusterIP"
    },
    {
      name  = "controller.service.name"
      value = "nginx-ingress-controller"
    }
  ]
}
```

### Exercise 7

Deploy a set of serverless apps using AWS API Gateway v2 and Python Lambda Functions.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise7

![AWS Serverless Architecture](/doc/lambda-arch.png)

Two Lambda functions are provisioned — `hello` and `pi` — each exposed through both a direct **Lambda Function URL** and an **API Gateway v2 HTTP API** route:

| Function | API Gateway Route         | Description                                                                                    |
| -------- | ------------------------- | ---------------------------------------------------------------------------------------------- |
| `hello`  | `GET /hello?name=<value>` | Returns a greeting message, optionally personalised with a `name` query parameter              |
| `pi`     | `GET /pi?num=<value>`     | Calculates and returns π to `num` decimal places using an iterative digit-extraction algorithm |

Both functions run on the **Python 3.14** runtime and are packaged from source at apply time using the `hashicorp/archive` provider.

The API Gateway `dev` stage is configured with **CloudWatch access logging** (30-day retention) capturing request metadata including source IP, HTTP method, route key, status code, and integration error messages.

A reusable local Terraform module (`./modules/lambda_function`) encapsulates the per-function resources — Lambda function, source code zip packaging, and Function URL — and is instantiated for each function via `for_each`:

```terraform
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
```

Each Lambda Function URL is created with open CORS and no authentication, making the functions directly invocable from a browser or `curl`:

```terraform
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
```

The API Gateway routes are wired to their respective Lambda functions via `AWS_PROXY` integrations:

```terraform
resource "aws_apigatewayv2_integration" "pi" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = module.lambda_function["pi"].invoke_arn
}

resource "aws_apigatewayv2_route" "pi" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /pi"
  target    = "integrations/${aws_apigatewayv2_integration.pi.id}"
}
```

After a successful `terraform apply`, four endpoint URLs are output:

- `hello_function_url` — direct Lambda Function URL for the `hello` function
- `hello_api_gateway_url` — API Gateway URL for `GET /hello`
- `pi_function_url` — direct Lambda Function URL for the `pi` function
- `pi_api_gateway_url` — API Gateway URL for `GET /pi`

#### Project Structure

```
├── api_gw.tf
├── main.tf
├── outputs.tf
├── vars.tf
├── archive
│   ├── fn.hello.zip
│   └── fn.pi.zip
├── fns
│   ├── hello
│   │   └── code
│   │       └── lambda_function.py
│   └── pi
│       └── code
│           └── lambda_function.py
└── modules
    └── lambda_function
        ├── main.tf
        ├── outputs.tf
        └── vars.tf
```

#### TF Variable Notes

The `lambda_functions` variable defines the list of Lambda functions to deploy. It has sensible defaults for both `hello` and `pi` — no configuration is required to run the exercise. The list can be extended to deploy additional functions by adding entries with the same object structure:

```hcl
variable "lambda_functions" {
  type = list(object({
    name          = string
    source_file   = string
    zip_file_name = string
    timeout       = number
    runtime       = string
  }))
  default = [
    {
      name          = "hello"
      source_file   = "./fns/hello/code/lambda_function.py"
      zip_file_name = "./archive/fn.hello.zip"
      timeout       = 60
      runtime       = "python3.14"
    },
    {
      name          = "pi"
      source_file   = "./fns/pi/code/lambda_function.py"
      zip_file_name = "./archive/fn.pi.zip"
      timeout       = 60
      runtime       = "python3.14"
    }
  ]
}
```
