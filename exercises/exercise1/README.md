## Exercise 1
Create a simple AWS VPC spanning 2 AZs. Public subnets will be created, together with an internet gateway, and single route table. A t3.micro instance will be deployed and installed with Nginx for web serving. Security groups will be created and deployed to secure all network traffic between the various components.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise1

![AWS Architecture](/doc/AWS-VPC-Nginx.png)

#### Project Structure

```
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### TF Variable Notes

- `key_name`: The Terraform variable `key_name` represents the AWS SSH Keypair name that will be used to allow SSH access to the Bastion Host that gets created at provisioning time. If you intend to use the Bastion Host - then you will need to create your own SSH Keypair (typically done within the AWS EC2 console) ahead of time.

  - The required Terraform `key_name` variable can be established multiple ways, one of which is to prefix the variable name with `TF_VAR_` and have it then set as an environment variable within your shell, something like:

  - **Linux**: `export TF_VAR_key_name=your_ssh_key_name`

  - **Windows**: `set TF_VAR_key_name=your_ssh_key_name`

- Terraform environment variables are documented here:
[https://www.terraform.io/cli/config/environment-variables](https://www.terraform.io/cli/config/environment-variables)