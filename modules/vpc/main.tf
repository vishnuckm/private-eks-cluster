#######modules/vpc/main.tf
resource "aws_vpc" "cloudquick" {
  cidr_block       = var.vpc_cidr 
  instance_tenancy = var.instance_tenancy
  tags = {
    Name = var.tags
  }
}

resource "aws_internet_gateway" "cloudquick_gw" {
  vpc_id = aws_vpc.cloudquick.id

  tags = {
    Name = var.tags
  }
}


data "aws_availability_zones" "available" {
}


resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = 2
}

resource "aws_subnet" "public_cloudquick_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.cloudquick.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = var.tags
  }
}

resource "aws_eip" "natgateway_eip" {
  #count = "${length(split(",", lookup(var.azs, var.region)))}"
  domain   = "vpc"
  tags = {
    Name = "eip nat poc"
  }
}

resource "aws_nat_gateway" "cloudquick_nat" {
  allocation_id = aws_eip.natgateway_eip.id
  subnet_id     = aws_subnet.public_cloudquick_subnet[0].id

  tags = {
    Name = "gw NAT poc"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  #depends_on = [aws_internet_gateway.example]
}

resource "aws_subnet" "private_cloudquick_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.cloudquick.id
  cidr_block              = var.private_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  #map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = var.tags2
  }
}


#resource "aws_default_route_table" "internal_cloudquick_default" {
#  default_route_table_id = aws_vpc.cloudquick.default_route_table_id

#  route {
#    cidr_block = var.rt_route_cidr_block
#    gateway_id = aws_internet_gateway.cloudquick_gw.id
#  }
#  tags = {
#    Name = var.tags
#  }
#}

resource "aws_route_table" "internal_cloudquick_public" {
  #default_route_table_id = aws_vpc.cloudquick.default_route_table_id
  vpc_id = aws_vpc.cloudquick.id
  route {
    cidr_block = var.rt_route_cidr_block
    gateway_id = aws_internet_gateway.cloudquick_gw.id
  }
  tags = {
    Name = var.tags
  }
}

resource "aws_route_table" "internal_cloudquick_private" {
  #default_route_table_id = aws_vpc.cloudquick.default_route_table_id
  vpc_id = aws_vpc.cloudquick.id
  route {
    cidr_block = var.rt_route_cidr_block
    nat_gateway_id = aws_nat_gateway.cloudquick_nat.id
  }
  tags = {
    Name = var.tags2
  }
}

resource "aws_route_table_association" "public" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_cloudquick_subnet[count.index].id
  route_table_id = aws_route_table.internal_cloudquick_public.id
}

resource "aws_route_table_association" "private" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.private_cloudquick_subnet[count.index].id
  route_table_id = aws_route_table.internal_cloudquick_private.id
}