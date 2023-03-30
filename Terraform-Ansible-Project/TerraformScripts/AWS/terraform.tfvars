#// VARS FOR TERRAFORM ts_for_vm_with_allConfiguration_settings FILE
machine_name        = "cartoon-network"
vpc_cidr_block      = "192.200.20.0/24"
subnet_cidr_block   = "192.200.20.0/27"
avail_zone          = "ap-south-1a"
env_prefix_tag          = "prod"
instance_type       = "t2.micro"
public_key_location = "C:\\Users\\UserNameofYourPC\\.ssh\\id_rsa.pub"
private_key_location = "C:\\Users\\UserNameofYourPC\\.ssh\\id_rsa"

#// VARS FOR TERRAFORM ts_for_vm_with_bareMinimum_configuration FILE

# machine_name             = "ansible-docker-server"
# env_prefix_tag           = "prod"
# private_key_location     = "C:\\Users\\UserNameofYourPC\\.ssh\\id_rsa.pub"
