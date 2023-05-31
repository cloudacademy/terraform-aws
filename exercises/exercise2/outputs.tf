output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet1_id" {
  value = aws_subnet.subnet1.id
}

output "subnet2_id" {
  value = aws_subnet.subnet2.id
}

output "subnet3_id" {
  value = aws_subnet.subnet3.id
}

output "subnet4_id" {
  value = aws_subnet.subnet4.id
}

output "alb_dns_name" {
  description = "alb dns"
  value       = aws_lb.alb1.dns_name
}

output "web_app_wait_command" {
  value       = "until curl --max-time 5 http://${aws_lb.alb1.dns_name} >/dev/null 2>&1; do echo preparing...; sleep 5; done; echo; echo -e 'Ready!!'"
  description = "Test command - tests readiness of the web app"
}
