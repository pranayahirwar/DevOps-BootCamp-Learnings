#In this script we are just providing bare minimum configuration for virtualmachine, rest will be taken care by AWS itself. 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "env_prefix_tag" {}
variable "private_key_location" {}
variable "machine_name" {}

# Creating EC2 Server and resource which will find the latest image from which EC2 will be created.
data "aws_ami" "latest_image_for_ec2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "Your_key_name" {
  key_name   = "localhost"
  public_key = "YourPublicKeyPasteHere."
}


resource "aws_instance" "cn-vm" {
  ami           = data.aws_ami.latest_image_for_ec2.id
  instance_type = "t2.micro"
  #   availability_zone      = var.avail_zone

  associate_public_ip_address = true

  key_name = aws_key_pair.Your_key_name.key_name


  #//This parameter is used to connect to ec2 instacne, when you want to execute some command on it.
  connection {
    type = "ssh"
    host = self.public_ip #Use this for IP-address and always remember to use self while playing with connection inside aws_instance block.
    user = "ec2-user"
    #password = "secret_password" # If you are not using SSH-Key you can provide password here.
    private_key = file(var.private_key_location)
  }

  #Local provisioner 
  provisioner "local-exec" {
    command = "echo Your IP is -> ${self.public_ip}"
  }

  tags = {
    Name = "${var.machine_name}-${var.env_prefix_tag}-vm-1"
  }
}

output "ami_name" {
  value = data.aws_ami.latest_image_for_ec2.name
}

output "ec2_ip_address" {
  value = aws_instance.cn-vm.public_ip
}