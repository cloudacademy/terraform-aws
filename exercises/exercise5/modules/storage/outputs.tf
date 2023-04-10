output "private_ip" {
  description = "private ip address"
  value       = aws_instance.mongo.private_ip
}