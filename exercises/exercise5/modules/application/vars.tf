variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(any)
}

variable "private_subnets" {
  type = list(any)
}

variable "webserver_sg_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "asg_desired" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 2
}

variable "asg_min_size" {
  type    = number
  default = 2
}
