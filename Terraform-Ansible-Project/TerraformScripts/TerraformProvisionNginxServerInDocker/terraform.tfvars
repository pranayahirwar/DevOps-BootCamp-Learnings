#Note- Add your own address otherwise terraform won't able to find SSH-key associated for your PC.

vpc_cidr_block       = "192.200.20.0/24"
subnet_cidr_block    = "192.200.20.0/27"
avail_zone           = "ap-south-1a"
env_prefix           = "dev"
instance_type        = "t2.micro"
public_key_location  = "C:\\Users\\Username\\.ssh\\id_rsa.pub"
private_key_location = "C:\\Users\\Username\\.ssh\\id_rsa"
