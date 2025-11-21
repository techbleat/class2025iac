terraform {
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


resource "aws_instance" "nginx-node" {
  ami                    = "ami-07e5795ae42ba2fb2"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-08cc6a7a9b660d73e"
  vpc_security_group_ids = ["sg-03e79c22dc0a1f610"]
  key_name               = "masterdevop"

  tags = {
    Name = "terraform-nginx-node"
  }
}


resource "aws_instance" "python-node" {
  ami                    = "ami-0e319259454f464e6"
  instance_type          = "t3.micro"
  subnet_id              = "subnet-08cc6a7a9b660d73e"
  vpc_security_group_ids = ["sg-03e79c22dc0a1f610"]
  key_name               = "masterdevop"

  tags = {
    Name = "terraform-python-node"
  }
}