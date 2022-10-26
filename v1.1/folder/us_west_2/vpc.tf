resource "aws_vpc" "main_west" {
  cidr_block = var.env == "dev" ? var.vpc_cidr_dev : var.vpc_cidr_qa
  tags = merge(local.common_tags, { Name = replace(local.name, "rtype", "vpc") }) 
}
resource "aws_subnet" "pub_sub_west" {
  count                   = length(var.env == "dev" ? var.cidr_pubs_dev : var.cidr_pubs_qa)
  vpc_id                  = aws_vpc.main_west.id
  cidr_block              = element(var.env == "dev" ? var.cidr_pubs_dev : var.cidr_pubs_qa, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs_west, count.index)
  tags = {
    "Name" = "${var.env}-public-subnet-${count.index}"
  }
}
resource "aws_subnet" "priv_sub_west" {
  count             = length(var.env == "dev" ? var.cidr_privs_dev : var.cidr_privs_qa)
  vpc_id            = aws_vpc.main_west.id
  cidr_block        = element(var.env == "dev" ? var.cidr_privs_dev : var.cidr_privs_qa, count.index)
  availability_zone = element(var.azs_west, count.index)
  tags = {
    "Name" = "${var.env}-private-subnet-${count.index}"
  }
}
resource "aws_internet_gateway" "internet_west" {
  vpc_id = aws_vpc.main_west.id
  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_nat_gateway" "nat_gw_west" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.pub_sub_west[0].id
  tags = {
    "Name" = "${var.env}-NGW"
  }
}
resource "aws_route_table" "pub-rt-west" {
  vpc_id = aws_vpc.main_west.id
  tags = {
    Name = "${var.env}-pub-rt"
  }
}
resource "aws_route_table" "priv-rt-west" {
  vpc_id = aws_vpc.main_west.id
  tags = {
    Name = "${var.env}-priv-rt"
  }
}
resource "aws_route" "internet-route-w" {
  route_table_id         = aws_route_table.pub-rt-west.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_west.id
}
resource "aws_route_table_association" "rt_pubsub-west" {
  count          = length(aws_subnet.pub_sub_west)
  subnet_id      = element(aws_subnet.pub_sub_west.*.id, count.index)
  route_table_id = aws_route_table.pub-rt-west.id
}
resource "aws_route_table_association" "rt_privsub-west" {
  count          = length(aws_subnet.priv_sub_west)
  subnet_id      = element(aws_subnet.priv_sub_west.*.id, count.index)
  route_table_id = aws_route_table.priv-rt-west.id
}
resource "aws_route" "nat-route-west" {
  route_table_id         = aws_route_table.priv-rt-west.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_west.id
}
