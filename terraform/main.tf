data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Amazon Linux 2023 x86_64 (region-specific, no hard-coded AMI id)
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.name_prefix}-"
  description = "SSH + HTTP for Ansible / Nginx class web nodes"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP (Nginx)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "amazon_linux_web" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.name_prefix}-amazon-linux-web"
    Role = "web"
    OS   = "amazon-linux-2023"
  }
}

resource "aws_instance" "ubuntu_web" {
  ami                         = data.aws_ami.ubuntu_jammy.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.name_prefix}-ubuntu-web"
    Role = "web"
    OS   = "ubuntu-jammy"
  }
}

# Ansible inventory with live public IPs (no copy/paste). Written on every terraform apply.
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../inventory/hosts.auto.ini"
  content  = <<-EOT
[web_amazon]
${aws_instance.amazon_linux_web.public_ip}

[web_ubuntu]
${aws_instance.ubuntu_web.public_ip}

[web:children]
web_amazon
web_ubuntu
EOT
}
