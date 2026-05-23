# variables.tf → defines structure

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "system_ip" {
  type = string
  default = "103.221.72.20"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default ="t3.micro"
}

variable "env" {
  type = string
  default = "dev"
}

variable "project_name" {
  type = string
  default = "day_64_server"
}

variable key_name {

}

#=================================================================

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
