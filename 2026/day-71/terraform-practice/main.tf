# Security Group
resource "aws_security_group" "demo_sg" {
  name        = "demo-sg"
  description = "Allow SSH"

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
  
  for_each = toset(["one", "two"])
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.demo_sg.id]  #security_groups is mainly for EC2-Classic & In VPC use vpc_security_group_ids
  key_name      = "my-key"

  tags = {
    Name        = "instance-${each.key}"
    #Name         = var.instance_name
    Terraform    = "true"
    Environment  = var.env
  }
}

