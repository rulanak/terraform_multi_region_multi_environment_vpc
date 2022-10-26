resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_route_table" "pub-route-table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-pub-rt"
  }
}
resource "aws_route_table" "priv-route-table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-priv-rt"
  }
}
resource "aws_route" "internet-route" {
  route_table_id         = aws_route_table.pub-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet.id

}
resource "aws_route_table_association" "rt_pubsub" {
  count          = length(aws_subnet.pub_sub)
  subnet_id      = element(aws_subnet.pub_sub.*.id, count.index)
  route_table_id = aws_route_table.pub-route-table.id
}
resource "aws_route_table_association" "rt_privsub-1" {
  count          = length(aws_subnet.priv_sub)
  subnet_id      = element(aws_subnet.priv_sub.*.id, count.index)
  route_table_id = aws_route_table.priv-route-table.id
}
resource "aws_route" "nat-route" {
  route_table_id         = aws_route_table.priv-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}
