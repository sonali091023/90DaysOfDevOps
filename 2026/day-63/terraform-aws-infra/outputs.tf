output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet"{
    value = aws_subnet.public_subnet.id
}

output "instance_id" {
  value = aws_instance.TerraWeek_Server.id
}

output "public_ip" {
  value = aws_instance.TerraWeek_Server.public_ip
}

output "public_dns"{
    value = aws_instance.TerraWeek_Server.public_dns
}

output "aws_security_group" {
  value = aws_security_group.ec2_sg.id
}
