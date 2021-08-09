output "dns_name" {
  description = "alb dns"
  value       = aws_lb.alb1.dns_name
}