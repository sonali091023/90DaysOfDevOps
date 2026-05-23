#Get available AZs in region
data "aws_availability_zones" "available" {
  state = "available"
}

#Get latest Amazon Linux 2 AMI
#Hardcoded AMI works only in one region.
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

#vpc
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

#subnet
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet"
  })
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

#route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route = []

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt"
  })
}

#Route Table Associationroute_table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

#security group
# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  # Incoming traffic to the application
  ingress {
    description = "HTTP Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.system_ip}/32"]
  }

  # Outgoing traffic from the application
  egress {
    description = "Allow All Outbound Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-sg"
  })
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("/home/sona/.ssh/id_ed25519.pub")
}

#ec2 instance
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -xe
    echo "<h1>Welcome to TerraWeek</h1>" | sudo tee /usr/share/nginx/html/index.html
  EOF

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}"
  })
}
