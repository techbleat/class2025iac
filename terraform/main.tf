terraform {
  backend "s3" {
    bucket  = "techbleat-cicd-state-bucket-week-7"
    key     = "envs/dev/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true

  }
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# -------------------------
# Web Node Security Group
# -------------------------

resource "aws_security_group" "web_sg" {

  name        = "web-sg"
  description = "Allow SSH and Port 80  inbound, all outbound"
  vpc_id      = var.project_vpc 


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 80 (web)
  ingress {
    description = "Web port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-security_group"
  }

}

#-------------------------
# Web EC2 Instance
# ------------------------


resource "aws_instance" "web-node" {
  ami                    = var.project_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               =  var.project_keyname

  tags = {
    Name = "web-node"
  }
}

# Python backend setup

resource "aws_security_group" "python_sg" {

  name        = "python-sg"
  description = "Allow SSH and Port 9000  inbound, all outbound"
  vpc_id      = var.project_vpc


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 9000 (app)
  ingress {
    description = "Python App port 9000"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "python-app-security_group"
  }

}

#-------------------------
# Python EC2 Instance
# ------------------------


resource "aws_instance" "python-node" {
  ami                    = var.project_ami
  instance_type          = var.project_instance_type
  subnet_id              = var.project_subnet
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  key_name               =  var.project_keyname

  tags = {
    Name = "python-node"
  }
}

# Java backend setup

resource "aws_security_group" "java_sg" {

  name        = "java-sg"
  description = "Allow SSH and Port 9090  inbound, all outbound"
  vpc_id      = "vpc-0981ae2afd0146876"


  # inbound SSH

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound 9090 (app)
  ingress {
    description = "Python App port 9090"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "java-app-security_group"
  }

}

#-------------------------
# Java EC2 Instance
# ------------------------


resource "aws_instance" "java-node" {
  ami                    = "ami-0f50f13aefb6c0a5d"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-08cc6a7a9b660d73e"
  vpc_security_group_ids = [aws_security_group.java_sg.id]
  key_name               = "devop-keypair"

  tags = {
    Name = "java-node"
  }
}


#--------------------------------
# Outputs - Public (external) IPs
#--------------------------------


output "web_node_ip" {
  description = " Public IP"
  value  = aws_instance.web-node.public_ip
}

output "python_node_ip" {
  description = " Public IP"
  value  = aws_instance.python-node.public_ip
}

output "java_node_ip" {
  description = " Public IP"
  value  = aws_instance.java-node.public_ip
}
