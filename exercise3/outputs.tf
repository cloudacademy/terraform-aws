output "alb_dns" {
  description = "alb dns"
  value       = module.application.dns_name
}

output "bastion_public_ip" {
  description = "bastion public ip"
  value       = module.bastion.public_ip
}

output "applicaiton_private_ips" {
  description = "application instance private ips"
  value       = module.application.applicaiton_private_ips
}

output "mongodb_private_ip" {
  description = "mongodb private ip"
  value       = module.storage.private_ip
}