resource "aws_eip" "eip_east" {
  vpc = true
  depends_on = [
    aws_internet_gateway.internet_east
  ]
}
resource "aws_eip" "eip_west" {
  provider = aws.us-west-2
  vpc = true
  depends_on = [
    aws_internet_gateway.internet_west
  ]
}