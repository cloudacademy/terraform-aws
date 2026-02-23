variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "cidr_block" {
  type        = string
  description = "VPC cidr block. Example: 10.10.0.0/16"

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$", var.cidr_block))
    error_message = "The cidr_block must be a valid IPv4 CIDR block (e.g. 10.10.0.0/16)."
  }
}
