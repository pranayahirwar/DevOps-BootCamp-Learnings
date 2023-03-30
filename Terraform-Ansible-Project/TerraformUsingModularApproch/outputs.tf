#This is root_main.tf output file, this file is used to display information of root_main.tf file. (root_main.tf = main.tf)
output "aws_instance_ip_address" {
  value = module.cn-net-webserver.vm_from_module_info.public_ip
}

# output "ami_name" {
#   value = data.aws_ami.latest_image_for_ec2.name
# }