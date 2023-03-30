terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "private_key_location" {}

resource "aws_vpc" "cn_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "cartoon-network-${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "cn_subnet" {
  vpc_id            = aws_vpc.cn_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "cartoon-network-${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "cn_gw" {
  vpc_id = aws_vpc.cn_vpc.id

  tags = {
    Name = "${var.env_prefix}-int-gatway"
  }
}

resource "aws_default_route_table" "cn-rt" {
  default_route_table_id = aws_vpc.cn_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cn_gw.id
  }
  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

resource "aws_default_security_group" "cn-sg" {
  vpc_id = aws_vpc.cn_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}


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

output "ami_name" {
  value = data.aws_ami.latest_image_for_ec2.name
}

resource "aws_key_pair" "deployer" {
  key_name   = "users-ssh-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "cn-vm" {
  ami           = data.aws_ami.latest_image_for_ec2.id
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.cn_subnet.id
  vpc_security_group_ids = [aws_default_security_group.cn-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  connection {
    type = "ssh"
    host = self.public_ip 
    user = "ec2-user"
    private_key = file(var.private_key_location)
  }
  provisioner "file" {
    source = "user_data_script.sh"
    destination = "/home/ec2-user/user_data_script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/user_data_script.sh",
      "cd /home/ec2-user",
      "./user_data_script.sh",

    ]
  }

  tags = {
    Name = "cartoon-net-${var.env_prefix}-vm-1"
  }
}

output "aws_instance_ip_address" {
  value = aws_instance.cn-vm.public_ip
}
