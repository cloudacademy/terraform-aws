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
