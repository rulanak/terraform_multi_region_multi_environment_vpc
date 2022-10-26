resource "aws_nat_gateway" "nat_gw" {
  //Do not use network_interface to associate the EIP to aws_lb or aws_nat_gateway resources. Instead use the allocation_id available in those resources to allow AWS to manage the association, otherwise you will see AuthFailure errors.
  allocation_id = aws_eip.eip.id
  //subnet id of the subnet in which to place the gateway
  subnet_id = aws_subnet.pub_sub[0].id
  tags = {
    "Name" = "${var.env}-NGW"
  }
}
