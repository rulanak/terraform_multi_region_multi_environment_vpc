resource "aws_vpc" "main_east" {
  cidr_block = var.env == "dev" ? var.vpc_cidr_dev : var.vpc_cidr_qa
  tags       = merge(local.common_tags, { Name = replace(local.name, "rtype", "vpc") })
}
resource "aws_subnet" "pub_sub_east" {
  count                   = length(var.env == "dev" ? var.cidr_pubs_dev : var.cidr_pubs_qa)
  vpc_id                  = aws_vpc.main_east.id
  cidr_block              = element(var.env == "dev" ? var.cidr_pubs_dev : var.cidr_pubs_qa, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs_east, count.index)
  tags = {
    "Name" = "${var.env}-public-subnet-${count.index}"
  }
}
resource "aws_subnet" "priv_sub_east" {
  count             = length(var.env == "dev" ? var.cidr_privs_dev : var.cidr_privs_qa)
  vpc_id            = aws_vpc.main_east.id
  cidr_block        = element(var.env == "dev" ? var.cidr_privs_dev : var.cidr_privs_qa, count.index)
  availability_zone = element(var.azs_east, count.index)
  tags = {
    "Name" = "${var.env}-private-subnet-${count.index}"
  }
}
resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.main_east.id
  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_nat_gateway" "nat_gw_east" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.pub_sub_east[0].id
  tags = {
    "Name" = "${var.env}-NGW"
  }
}
resource "aws_route_table" "pub-rt-east" {
  vpc_id = aws_vpc.main_east.id
  tags = {
    Name = "${var.env}-pub-rt"
  }
}
resource "aws_route_table" "priv-rt-east" {
  vpc_id = aws_vpc.main_east.id
  tags = {
    Name = "${var.env}-priv-rt"
  }
}
resource "aws_route" "internet-route-e" {
  route_table_id         = aws_route_table.pub-rt-east.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet.id

}
resource "aws_route_table_association" "rt_pubsub-east" {
  count          = length(aws_subnet.pub_sub_east)
  subnet_id      = element(aws_subnet.pub_sub_east.*.id, count.index)
  route_table_id = aws_route_table.pub-rt-east.id
}
resource "aws_route_table_association" "rt_privsub-east" {
  count          = length(aws_subnet.priv_sub_east)
  subnet_id      = element(aws_subnet.priv_sub_east.*.id, count.index)
  route_table_id = aws_route_table.priv-rt-east.id
}
resource "aws_route" "nat-route-east" {
  route_table_id         = aws_route_table.priv-rt-east.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_east.id
}
