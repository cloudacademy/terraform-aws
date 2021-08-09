output "webserver_sg_id" {
  description = "web server sg id"
  value       = aws_security_group.webserver.id
}

output "alb_sg_id" {
  description = "alb sg id"
  value       = aws_security_group.alb.id
}

output "mongodb_sg_id" {
  description = "mongodb sg id"
  value       = aws_security_group.mongodb.id
}

output "bastion_sg_id" {
  description = "bastion sg id"
  value       = aws_security_group.bastion.id
}
