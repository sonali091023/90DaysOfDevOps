resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TerraWeek-VPC"
  }
}

#public subnet
#public subnet inside vpc
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

#internet gateway
#Connects vpc to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraweek-igw"
  }
}

#route table
#routes traffic from subnet to IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Terraweek-public-rt"
  }
}

#route table association with subnet/Link route table with subnet
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

#Security group SSH-22 HTTP-80
# Firewall: allow SSH & HTTP, all outbound
resource "aws_security_group" "ec2_sg" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #cidr_blocks = ["YOUR.IP.ADDRESS/32"]    best practice
  }

  ingress {
    description = "Allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbounds"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }

}

resource "aws_instance" "TerraWeek_Server" {
  ami                         = "ami-091138d0f0d41ff90"
  instance_type               = "t3.micro"
  key_name                    = "terraweakkp"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  #Square brackets are required because Terraform expects a list, even for a single security group.

  user_data = <<-EOF
             #!/bin/bash
	     set -xe
             sudo apt update -y
             sudo apt install nginx -y
             sudo systemctl start nginx
             sudo systemctl enable nginx
             echo "<h1>Welcome to TerraWeek</h1>" | sudo tee /var/www/html/index.html
             EOF

  tags = {
    Name = "TerraWeek-Server"
  }


}







