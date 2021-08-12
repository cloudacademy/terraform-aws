variable "instance_type" {}
variable "key_name" {}
variable "vpc_id" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "webserver_sg_id" {}
variable "alb_sg_id" {}
variable "mongodb_ip" {}

variable "asg_desired" {
    type = number
    default = 2
}
variable "asg_max_size" {
    type = number
    default = 2
}
variable "asg_min_size" {
    type = number
    default = 2
}
  