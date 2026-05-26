variable "vpc_cidr" {}

variable "public_subnet_cidr" {}

variable "environment" {}

variable "project_name" {}

variable "ami_id" {}

variable "instance_type" {}

variable "ingress_ports" {
  type = list(number)
}

variable aws_region {}
