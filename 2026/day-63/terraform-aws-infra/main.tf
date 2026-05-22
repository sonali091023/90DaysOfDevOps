# Get available AZs in region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2 AMI
# Hardcoded AMI works only in one region.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  /*
  tags = {
    # Name        = "${var.project_name}-${var.env}-vpc" # old
    Name        = "${local.name_prefix}-vpc" # new with locals.tf
    Environment = var.env
  }
  */

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  /*
  tags = {
    # Name = "${var.project_name}-${var.env}-subnet"
    Name = "${local.name_prefix}-subnet"
  }
  */

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  /*
  tags = {
    # Name = "${var.project_name}-${var.env}-igw"
    Name = "${local.name_prefix}-igw"
  }
  */

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  /*
  tags = {
    # Name = "${var.project_name}-${var.env}-rt"
    Name = "${local.name_prefix}-rt"
  }
  */

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt"
  })
}

# Route Table Association
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.env}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /*
  tags = {
    # Name = "${var.project_name}-${var.env}-sg"
    Name = "${local.name_prefix}-sg"
  }
  */

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("/home/sona/.ssh/id_ed25519.pub")
}

# EC2 Instance
resource "aws_instance" "terraweek_server" {
  ami                    = data.aws_ami.amazon_linux.id
  #instance_type          = var.instance_type
  instance_type = var.env == "prod" ? "t3.small" : "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -xe

    sudo yum update -y

    # Install Nginx
    sudo amazon-linux-extras install nginx1 -y
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Install Docker
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker

    sudo usermod -aG docker ec2-user

    echo "<h1>Welcome to TerraWeek</h1>" | sudo tee /usr/share/nginx/html/index.html
  EOF

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-server"
  })
}
