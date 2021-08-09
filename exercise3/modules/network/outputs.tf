output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.main.id
}

output "subnet1_id" {
  description = "subnet id"
  value       = aws_subnet.subnet1.id
}

output "subnet2_id" {
  description = "subnet id"
  value       = aws_subnet.subnet2.id
}

output "subnet3_id" {
  description = "subnet id"
  value       = aws_subnet.subnet3.id
}

output "subnet4_id" {
  description = "subnet id"
  value       = aws_subnet.subnet4.id
}
