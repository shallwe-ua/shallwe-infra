resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "${local.name_prefix}-main-vpc"
  }
}


resource "aws_subnet" "main-0" {
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
}

resource "aws_subnet" "main-16" {
  cidr_block              = "172.31.16.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
}

resource "aws_subnet" "main-32" {
  cidr_block              = "172.31.32.0/20"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
}
