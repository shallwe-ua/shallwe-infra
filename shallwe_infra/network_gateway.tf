resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-main-ig"
  }
}


resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}


resource "aws_route_table_association" "main-0" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.main-0.id
}

resource "aws_route_table_association" "main-16" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.main-16.id
}

resource "aws_route_table_association" "main-32" {
  route_table_id = aws_route_table.main.id
  subnet_id      = aws_subnet.main-32.id
}
