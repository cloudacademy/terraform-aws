variable "key_name" {
    type = string
}

variable "workstation_ip" {
    type = string
}

variable "environment" {
    type = string
    default = "demo"
}

variable "region" {
    type = string
}

variable "cidr_block" {
    type        = string
    description = "VPC cidr block. Example: 10.10.0.0/16"
}

variable "availability_zones" {
    type = list
}

variable "bastion_instance_type" {
    type = string
}

variable "app_instance_type" {
    type = string
}

variable "db_instance_type" {
    type = string
}