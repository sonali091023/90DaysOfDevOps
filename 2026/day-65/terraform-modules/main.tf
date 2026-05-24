# Create VPC

#resource "aws_vpc" "main" {
#  cidr_block = "10.0.0.0/16"
#
#  tags = {
#    Name = "terraweek-vpc"
#  }
#}

#Create Public Subnet
#resource "aws_subnet" "public" {
#  vpc_id                  = aws_vpc.main.id
#  cidr_block              = "10.0.1.0/24"
#  map_public_ip_on_launch = true
#
#  tags = {
#    Name = "terraweek-public-subnet"
#  }
#}

#VPC Registry Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  #version = "~> 5.0"                               #any 5.x version
  version = "5.1.0"                                 #pinning the exact version      
  #version = ">= 5.0, < 6.0"                        #range

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Call Security Group Module
module "web_sg" {
  source = "./modules/security-group"

  #vpc_id        = aws_vpc.main.id
  vpc_id = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}

# Call EC2 Module - Web Server
module "web_server" {
  source = "./modules/ec2-instance"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  #subnet_id          = aws_subnet.public.id
  subnet_id = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "day-65-server"
  tags               = local.common_tags
}

# Call EC2 Module - API Server
module "api_server" {
  source = "./modules/ec2-instance"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  #subnet_id          = aws_subnet.public.id
  subnet_id = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "day-65-server"
  tags               = local.common_tags
}
