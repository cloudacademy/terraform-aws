## Exercise 3
Same AWS architecture as used in Exercise 2. This exercise demonstrates a different Terraform technique, using the Terraform "count" meta argument, for configuring the public and private subnets as well as their respective route tables.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise3

![AWS Architecture](/doc/AWS-VPC-ASG-Nginx.png)

#### Project Structure

```
├── ec2.userdata
├── main.tf
├── outputs.tf
├── terraform.tfvars
└── variables.tf
```

#### TF Variable Notes

- `workstation_ip`: The Terraform variable `workstation_ip` represents your workstation's external perimeter public IP address, and needs to be represented using CIDR notation. This IP address is used later on within the Terraform infrastructure provisioning process to lock down SSH access on the instance(s) (provisioned by Terraform) - this is a security safety measure to prevent anyone else from attempting SSH access. The public IP address will be different and unique for each user - the easiest way to get this address is to type "what is my ip address" in a google search. As an example response, lets say Google responded with `202.10.23.16` - then the value assigned to the Terraform `workstation_ip` variable would be `202.10.23.16/32` (note the `/32` is this case indicates that it is a single IP address).

- `key_name`: The Terraform variable `key_name` represents the AWS SSH Keypair name that will be used to allow SSH access to the Bastion Host that gets created at provisioning time. If you intend to use the Bastion Host - then you will need to create your own SSH Keypair (typically done within the AWS EC2 console) ahead of time.

  - The required Terraform `workstation_ip` and `key_name` variables can be established multiple ways, one of which is to prefix the variable name with `TF_VAR_` and have it then set as an environment variable within your shell, something like:

  - **Linux**: `export TF_VAR_workstation_ip=202.10.23.16/32` and `export TF_VAR_key_name=your_ssh_key_name`

  - **Windows**: `set TF_VAR_workstation_ip=202.10.23.16/32` and `set TF_VAR_key_name=your_ssh_key_name`

- Terraform environment variables are documented here:
[https://www.terraform.io/cli/config/environment-variables](https://www.terraform.io/cli/config/environment-variables)