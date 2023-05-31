output "alb_dns" {
  description = "alb dns"
  value       = module.application.dns_name
}

output "bastion_public_ip" {
  description = "bastion public ip"
  value       = module.bastion.public_ip
}

output "application_private_ips" {
  description = "application instance private ips"
  value       = module.application.private_ips
}

output "mongodb_private_ip" {
  description = "mongodb private ip"
  value       = module.storage.private_ip
}

output "web_app_wait_command" {
  value       = "until curl --max-time 5 http://${module.application.dns_name} >/dev/null 2>&1; do echo preparing...; sleep 5; done; echo; echo -e 'Ready!!'"
  description = "Test command - tests readiness of the web app"
}
