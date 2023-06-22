output "windows_instance_public_ip" {
  value = aws_instance.server.public_ip
}

#CAUTION - doing this for demo purposes only
output "windows_admin_password" {
  value     = rsadecrypt(aws_instance.server.password_data, file("${aws_key_pair.key_pair.key_name}.pem"))
  sensitive = true
}
