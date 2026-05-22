# variables.tf → defines structure

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ami_id" {
  #type    = string
  #default = "ami-0a59ec92177ec3fad"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "key_name" {
  type    = string
  default = "terraweakkp"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_pair_map" {
  description = "Key pair per environment"
  type        = map(string)

  default = {
    dev   = "de-key"
    stage = "stage-key"
    prod  = "prod-key"
  }
}

# Multiple port numbers
variable "allowed_ports" {
  description = "List of allowed inbound ports"
  type        = list(number)

  default = [22, 80, 443]
}

# Extra tags
variable "extra_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)

  default = {}
}
