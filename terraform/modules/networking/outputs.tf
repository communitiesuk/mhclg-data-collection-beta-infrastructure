output "aws_pub_subnet" {
  value = aws_subnet.pub_subnet
  description = "AWS subnets"
}

output "aws_vpc" {
  value = aws_vpc.vpc
  description = "AWS VPC"
}
