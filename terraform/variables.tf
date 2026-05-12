variable "aws_region" {
  type        = string
  description = "Region to create both instances in (must match your AWS CLI / console region)."
  default     = "eu-west-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 size (t3.micro is free-tier eligible in many accounts)."
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Name of an existing EC2 key pair in this region (the .pem you use for ansible_user SSH)."
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH (port 22). Use your public IP/32 in production; 0.0.0.0/0 is open to the world."
  default     = "0.0.0.0/0"
}

variable "name_prefix" {
  type        = string
  description = "Tag prefix for the two instances."
  default     = "class-web"
}
