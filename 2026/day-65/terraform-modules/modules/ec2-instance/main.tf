#aws_instance → AWS EC2 resource & "this" → local Terraform name
resource "aws_instance" "instance" {               
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  #This combines: custom tags, Name tag
  tags = merge(    
    var.tags,
    {
      Name = var.instance_name
    }
  )
}
