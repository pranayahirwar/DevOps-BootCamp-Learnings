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

resource "aws_vpc" "cn_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "cartoon-network-${var.env_prefix}-vpc"
  }
}

#Using subnet module
module "cn-net-subnet" {
  source = "./modules/subnet"
  aws_passed_vpc_in_module_id = aws_vpc.cn_vpc.id
  passed_default_route_table_id = aws_vpc.cn_vpc.default_route_table_id
  subnet_cidr_block_in_module = var.subnet_cidr_block
  avail_zone_in_module = var.avail_zone
  env_prefix_in_module = var.env_prefix
}

#Using Webserver module
module "cn-net-webserver" {
  source = "./modules/webserver"
  aws_passed_vpc_in_module_id = aws_vpc.cn_vpc.id
  env_prefix_in_module = var.env_prefix
  public_key_location_in_module = var.public_key_location
  avail_zone_in_module = var.avail_zone
  #This information is coming from subnet module output file.
  passed_subnet_id_from_module = module.cn-net-subnet.subnet_module_subnet_info.id

}


