output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet1_id" {
  value = aws_subnet.subnet1.id
}

output "subnet2_id" {
  value = aws_subnet.subnet2.id
}

output "web_instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_app_wait_command" {
  value       = "until curl --max-time 5 http://${aws_instance.web.public_ip} >/dev/null 2>&1; do echo preparing...; sleep 5; done; echo; echo -e 'Ready!!'"
  description = "Test command - tests readiness of the web app"
}
