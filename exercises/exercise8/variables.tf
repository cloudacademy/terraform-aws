variable "windows_instance_name" {
  type        = string
  description = "Windows Server EC2 instance name"
  default     = "winsrv01-cloudacademy"
}

variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t2.small"
}

variable "windows_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}

variable "windows_root_volume_type" {
  type        = string
  description = "Windows Server root volume type"
  default     = "gp3"
}

variable "windows_root_volume_size" {
  type        = number
  description = "Windows Server root volume size"
  default     = "30"
}

variable "windows_data_volume_type" {
  type        = string
  description = "Windows Server data volume type"
  default     = "gp3"
}

variable "windows_data_volume_size" {
  type        = number
  description = "Windows Server data volume size"
  default     = "50"
}
