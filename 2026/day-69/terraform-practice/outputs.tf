output "instance_details" {
  value = {
    id         = aws_instance.instance.id
    public_ip  = aws_instance.instance.public_ip
  }
}

