output "amazon_linux_public_ip" {
  description = "Public IP for Ansible group web_amazon (ansible_user=ec2-user)"
  value       = aws_instance.amazon_linux_web.public_ip
}

output "ubuntu_public_ip" {
  description = "Public IP for Ansible group web_ubuntu (ansible_user=ubuntu)"
  value       = aws_instance.ubuntu_web.public_ip
}

output "ansible_inventory_snippet" {
  description = "Same content as inventory/hosts.auto.ini (written automatically by Terraform)"
  value       = <<-EOT
    [web_amazon]
    ${aws_instance.amazon_linux_web.public_ip}

    [web_ubuntu]
    ${aws_instance.ubuntu_web.public_ip}

    [web:children]
    web_amazon
    web_ubuntu
  EOT
}
