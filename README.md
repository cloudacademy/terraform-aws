# CloudAcademy Terraform 1.x AWS Course
This repo contains example Terraform configurations for building AWS infrastructure.

## AWS Exercises
The exercises directory contains 4 different AWS infrastructure provisioning exercises. 

### Exercise 1
Create a simple AWS VPC spanning 2 AZs. Public subnets will be created, together with an Internet Gateway, and single Route Table. A t3.micro instance will be deployed and installed with Nginx for web serving.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise1

![AWS Architecture](./doc/AWS-VPC-Nginx.png)

### Exercise 2
Create an advanced AWS VPC spanning 2 AZs with both Public and Private subnets. An Internet Gateway and NAT Gateway will be deployed into it. Public and private route tables will be established. An Application Load Balancer (ALB) will be installed which will load balancer traffic across an Auto Scaling Group (ASG) of Nginx web servers.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise2

![AWS Architecture](./doc/AWS-VPC-ASG-Nginx.png)

### Exercise 3
Create an advanced AWS VPC spanning 2 AZs with both Public and Private subnets. An Internet Gateway and NAT Gateway will be deployed into it. Public and private route tables will be established. An Application Load Balancer (ALB) will be installed which will load balance traffic across an Auto Scaling Group (ASG) of Nginx web servers.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise3

![AWS Architecture](./doc/AWS-VPC-ASG-Nginx.png)

### Exercise 4
Create an advanced AWS VPC to host a fully functioning cloud native application. The VPC will span 2 AZs, and have both Public and Private subnets. An Internet Gateway and NAT Gateway will be deployed into it. Public and private route tables will be established. An Application Load Balancer (ALB) will be installed which will load balance traffic across an Auto Scaling Group (ASG) of Nginx web servers installed with a cloud native application. A database instance running MongoDB will be installed in the Private zone.

https://github.com/cloudacademy/terraform-aws/tree/main/exercises/exercise4

![AWS Architecture](./doc/AWS-VPC-FullApp.png)
