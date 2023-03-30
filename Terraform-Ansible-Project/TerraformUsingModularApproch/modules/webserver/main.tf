resource "aws_default_security_group" "cn-sg" {
  vpc_id = var.aws_passed_vpc_in_module_id

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
    Name = "${var.env_prefix_in_module}-sg"
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

resource "aws_key_pair" "deployer" {
  key_name   = "users-ssh-key"
  public_key = file(var.public_key_location_in_module)
}

resource "aws_instance" "cn-vm" {
  ami           = data.aws_ami.latest_image_for_ec2.id
  instance_type = "t2.micro"

  subnet_id              = var.passed_subnet_id_from_module
  vpc_security_group_ids = [aws_default_security_group.cn-sg.id]
  availability_zone      = var.avail_zone_in_module

  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  tags = {
    Name = "cartoon-net-${var.env_prefix_in_module}-vm-1"
  }
}