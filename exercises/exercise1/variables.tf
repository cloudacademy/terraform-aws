variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "workstation_ip" {
  type = string
}

variable "amis" {
  type = map(any)
  default = {
    "us-east-2" : "ami-02238ac43d6385ab3"
    "us-west-2" : "ami-0df24e148fdb9f1d8"
  }
}