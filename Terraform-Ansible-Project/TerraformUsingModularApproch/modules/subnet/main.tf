resource "aws_subnet" "cn_subnet" {
  vpc_id            = var.aws_passed_vpc_in_module_id
  cidr_block        = var.subnet_cidr_block_in_module
  availability_zone = var.avail_zone_in_module
  tags = {
    Name = "cartoon-network-${var.env_prefix_in_module}-subnet-1"
  }
}
resource "aws_subnet" "cn_subnet-1" {
  vpc_id            = var.aws_passed_vpc_in_module_id
  cidr_block        = "192.200.20.32/27"
  availability_zone = var.avail_zone_in_module
  tags = {
    Name = "cartoon-network-${var.env_prefix_in_module}-subnet-2"
  }
}

resource "aws_internet_gateway" "cn_gw" {
  vpc_id = var.aws_passed_vpc_in_module_id

  tags = {
    Name = "${var.env_prefix_in_module}-int-gatway"
  }
}

resource "aws_default_route_table" "cn-rt" {
  default_route_table_id = var.passed_default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cn_gw.id
  }
  tags = {
    Name = "${var.env_prefix_in_module}-route-table"
  }
}