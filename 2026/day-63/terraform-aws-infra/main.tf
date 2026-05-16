locals {
  selected_instance_type = var.instance_type_map[var.env]
  selected_key_pair= var.key_pair_map[var.env]
  name_prefix = "${var.project_name}-${var.env}"

  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

# Get available AZs in region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux AMI
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

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-vpc"
})
}

#public subnet
#public subnet inside vpc
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]     #Get all AZs & Pick the first one
  
  tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-subnet"
})
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

dynamic "ingress" {
    for_each = var.allowed_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      #cidr_blocks = ["YOUR.IP.ADDRESS/32"]    best practice
    }
  }
/* ingress {
  description = "Allow SSH"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  #cidr_blocks = ["YOUR.IP.ADDRESS/32"]    best practice

}

ingress {
  description = "Allow http"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
} */

egress {
  description = "Allow all outbounds"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
}

tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-sg"
})

}

#Terraform creating key itself
resource "aws_key_pair" "deployer" {
  key_name   = local.selected_key_pair
  public_key = file("/home/sona/.ssh/id_ed25519.pub")   #~/Terraform treats it as a literal path, so to avoid failure replace that with your systems path
}

resource "aws_instance" "TerraWeek_Server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.env == "prod" ? "t3.small" : "t2.micro"    #[condition ? true_value : false_value== It means if env = prod then t3.small else t3.micro]
  key_name     = aws_key_pair.deployer.key_name                          #dynamic key, We can set only one key_pair at a time
  subnet_id     = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  #Square brackets are required because Terraform expects a list, even for a single security group.
  
  user_data = <<-EOF
             #!/bin/bash
             set -xe
             sudo dnf update -y
             sudo dnf install -y nginx
             systemctl start nginx
             systemctl enable nginx
             echo "<h1>Welcome to TerraWeek</h1>" > /usr/share/nginx/html/index.html
             EOF

  #Instead of writing tags manually, merge them, It Combines default tags plus extra tags
  tags = merge(
  local.common_tags,
  {
    Name = "${local.name_prefix}-server"
  },
  var.extra_tags
)

}







