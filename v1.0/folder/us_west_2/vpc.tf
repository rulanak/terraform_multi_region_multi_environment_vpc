resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "${var.env}_vpc"
  }
}
resource "aws_subnet" "pub_sub" {
  count                   = length(var.cidr_pubs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.cidr_pubs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)
  tags = {
    "Name" = "${var.env}-public-subnet-${count.index}"
  }
}
resource "aws_subnet" "priv_sub" {
  count             = length(var.cidr_privs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.cidr_privs, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    "Name" = "${var.env}-private-subnet-${count.index}"
  }
}