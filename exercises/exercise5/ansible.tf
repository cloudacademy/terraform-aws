resource "null_resource" "ansible" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}/ansible"
    command     = <<EOT
      sleep 120 #time to allow VMs to come online and stabilize
      mkdir -p ./logs

      sed \
      -e 's/BASTION_IP/${module.bastion.public_ip}/g' \
      -e 's/WEB_IPS/${join("\\n", module.application.private_ips)}/g' \
      -e 's/MONGO_IP/${module.storage.private_ip}/g' \
      ./templates/hosts > hosts

      sed \
      -e 's/BASTION_IP/${module.bastion.public_ip}/g' \
      -e 's/SSH_KEY_NAME/${var.key_name}/g' \
      ./templates/ssh_config > ssh_config

      #required for macos only
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

      #ANSIBLE
      ansible-playbook -v \
      -i hosts \
      --extra-vars "ALB_DNS=${module.application.dns_name}" \
      --extra-vars "MONGODB_PRIVATEIP=${module.storage.private_ip}" \
      ./playbooks/master.yml
      echo finished!
    EOT
  }

  depends_on = [
    module.bastion,
    module.application
  ]
}
