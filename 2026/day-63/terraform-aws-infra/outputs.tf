output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet"{
    value = aws_subnet.public_subnet.id
}

output "instance_id" {
  value = aws_instance.terraweek_server.id
}

output "public_ip" {
  value = aws_instance.terraweek_server.public_ip
}

output "public_dns" {
  value = aws_instance.terraweek_server.public_dns
}

output "aws_security_group" {
  value = aws_security_group.ec2_sg.id
}
