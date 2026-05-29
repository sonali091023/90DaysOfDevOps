output "instance_public_ips" {
  value = {
    for key, instance in aws_instance.instance :
    key => instance.public_ip
  }
}
