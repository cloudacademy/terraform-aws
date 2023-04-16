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
