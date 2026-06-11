output "instance_details" {
  value = {
    for key, instance in aws_instance.instance :
    key => {
      id        = instance.id
      public_ip = instance.public_ip
    }
  }
}


#output "instance_details" {
#  value = {
#    id         = instance.id
#    public_ip  = instance.public_ip
#  }
#}
