# -----------------------------------
# VPC
# -----------------------------------
resource "aws_vpc" "vpc1" {
  cidr_block           = "100.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc1"
  }
}
# -----------------------------------
# subnets
# -----------------------------------
# public subnets
resource "aws_subnet" "public" {
  for_each = {
    "100.1.1.0/24" = "us-east-1a"
    "100.1.2.0/24" = "us-east-1c"
    "100.1.3.0/24" = "us-east-1d"
  }
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = each.key
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags = {
    Name = "vpc1_public_${each.value}"
  }
}
# private subnets
resource "aws_subnet" "private" {
  for_each = {
    "100.1.129.0/24" = "us-east-1a"
    "100.1.130.0/24" = "us-east-1c"
    "100.1.131.0/24" = "us-east-1d"
  }
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = each.key
  availability_zone       = each.value
  map_public_ip_on_launch = false
  tags = {
    Name = "vpc1_private_${each.value}"
  }
}
# -----------------------------------
# Internet gateway
# -----------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc1_gw"
  }
}
# -----------------------------------
# Route tables
# -----------------------------------
# a route table on public subnets to a Internet gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "public_rt"
  }
}
resource "aws_route" "public_to_gw_r" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
  route_table_id         = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_rta" {
  route_table_id = aws_route_table.public_rt.id
  for_each = {
    "100.1.1.0/24" = "us-east-1a"
    "100.1.2.0/24" = "us-east-1c"
    "100.1.3.0/24" = "us-east-1d"
  }
  subnet_id = aws_subnet.public[each.key].id
}
# a route table on private subnets just to disuse default route table 
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "private_rt"
  }
}
resource "aws_route_table_association" "private_rta" {
  route_table_id = aws_route_table.private_rt.id
  for_each = {
    "100.1.129.0/24" = "us-east-1a"
    "100.1.130.0/24" = "us-east-1c"
    "100.1.131.0/24" = "us-east-1d"
  }
  subnet_id = aws_subnet.private[each.key].id
}