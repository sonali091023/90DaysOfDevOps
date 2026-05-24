# variables.tf → defines structure

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type = string
  default = "day_65_server"
}

variable "environment" {
  type = string
  default = "dev"
}

variable instance_type {
  type = string
  default = "t3.micro"
}
