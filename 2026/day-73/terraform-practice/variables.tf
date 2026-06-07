variable region {}
variable instance_type {}
variable ssh_key {}
variable subnet_id {}
variable env {}
variable vpc_id {}
variable ami_id {}
variable instance_name {}
variable "ingress_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)
}
