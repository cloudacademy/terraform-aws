output "public_ip" {
  description = "public ip address"
  value       = aws_instance.bastion.public_ip
}