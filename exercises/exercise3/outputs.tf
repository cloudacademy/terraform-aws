output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}

output "public_cidrs" {
  value = aws_subnet.public.*.cidr_block
}

output "private_subnets" {
  value = aws_subnet.private.*.id
}

output "private_cidrs" {
  value = aws_subnet.private.*.cidr_block
}

output "alb_dns_name" {
  description = "alb dns"
  value       = aws_lb.alb1.dns_name
}

output "bastion_public_ip" {
  description = "bastion public ip"
  value       = aws_instance.bastion.public_ip
}

output "webserver_private_ips" {
  description = "webserver private ips"
  value       = data.aws_instances.webserver.private_ips
}

output "web_app_wait_command" {
  value       = "until curl --max-time 5 http://${aws_lb.alb1.dns_name} >/dev/null 2>&1; do echo preparing...; sleep 5; done; echo; echo -e 'Ready!!'"
  description = "Test command - tests readiness of the web app"
}
