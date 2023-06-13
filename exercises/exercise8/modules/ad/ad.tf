resource "aws_directory_service_directory" "my_microsoftad" {
  type       = "MicrosoftAD"
  name       = var.domain_name
  short_name = var.short_name
  edition    = var.edition
  password   = var.admin_password

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }
}

resource "aws_vpc_dhcp_options" "my_microsoftad_dhcp" {
  domain_name         = var.domain_name
  domain_name_servers = aws_directory_service_directory.my_microsoftad.dns_ip_addresses
}

resource "aws_vpc_dhcp_options_association" "my_microsoftad_dns_resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.my_microsoftad_dhcp.id
}

