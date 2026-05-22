# ==========================================
# VPC
# Creates a private network in AWS
# ==========================================
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TerraWeek-VPC"
  }
}

# ==========================================
# Public Subnet
# Public subnet inside the VPC
# ==========================================
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraWeek-Public-Subnet"
  }
}

# ==========================================
# Internet Gateway
# Connects VPC to the Internet
# ==========================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "TerraWeek-IGW"
  }
}

# ==========================================
# Public Route Table
# Routes internet traffic to IGW
# ==========================================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "TerraWeek-Public-RT"
  }
}

# ==========================================
# Route Table Association
# Links route table with subnet
# ==========================================
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================================
# Security Group
# Allows SSH (22) and HTTP (80)
# ==========================================
resource "aws_security_group" "ec2_sg" {
  name        = "TerraWeek-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc.id

  # -----------------------------
  # Inbound Rules
  # -----------------------------

  ingress {
    description = "Allow SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

    # Best Practice:
    # cidr_blocks = ["YOUR.IP.ADDRESS/32"]
  }

  ingress {
    description = "Allow HTTP"

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  # -----------------------------
  # Outbound Rules
  # -----------------------------

  egress {
    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraWeek-SG"
  }
}

# ==========================================
# EC2 Instance
# Launches Amazon Linux Server
# ==========================================
resource "aws_instance" "TerraWeek_Server" {

  ami           = "ami-091138d0f0d41ff90"
  instance_type = "t3.micro"

  key_name = "terraweakkp"

  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  # --------------------------------
  # Lifecycle Rule
  # Create new instance first,
  # then destroy old one
  # --------------------------------
  lifecycle {
    create_before_destroy = true
  }

  # --------------------------------
  # User Data Script
  # Installs and starts NGINX
  # --------------------------------
  user_data = <<-EOF
              #!/bin/bash
              set -xe

              sudo dnf update -y
              sudo dnf install -y nginx

              sudo systemctl start nginx
              sudo systemctl enable nginx

              echo "<h1>Welcome to TerraWeek</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "TerraWeek-Server"
  }
}

# ==========================================
# Output
# Displays EC2 Public IP
# ==========================================
output "public_ip" {
  value = aws_instance.TerraWeek_Server.public_ip
}







