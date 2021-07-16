resource "aws_subnet" "pub_subnet" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "eu-west-2a"

  tags = var.default_tags
}

resource "aws_subnet" "pub2_subnet" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "eu-west-2b"

  tags = var.default_tags
}
