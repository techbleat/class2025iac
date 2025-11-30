terraform {
  backend "s3" {
    bucket  = "techbleat-cicd-state-bucket"
    key     = "envs/dev/terraform.tfstate"
    region  = "eu-west-1"
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
  region = "eu-west-1"
}

# -------------------------
# Web Node Security Group
# -------------------------

resource "aws_security_group" "web_sg" {

  name        = "web-sg"
  description = "Allow SSH and Port 80  inbound, all outbound"
  vpc_id      = "vpc-0a1624f291bfb283f"


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
# EC2 Instances
# ------------------------


resource "aws_instance" "web-node" {
  ami                    = "ami-08b6a2983df6e9e25"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-060ba13bd6800a0db"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "MasterClass2025"

  tags = {
    Name = "web-node"
  }
}
