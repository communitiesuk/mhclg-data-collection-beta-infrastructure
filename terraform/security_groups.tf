resource "aws_security_group" "lb_security_group" {
  name = "lb-sg"
  description = "Controls access to the application Load Balancer"
  vpc_id = aws_vpc.vpc.id

  tags = var.default_tags

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs-sg"
  description = "ECS Security Group"
  vpc_id      = aws_vpc.vpc.id
  tags        = var.default_tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_groups = [aws_security_group.lb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds_security_group" {
  name        = "rds-sg"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.vpc.id
  tags        = var.default_tags

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # TODO limit this to just ECS IP range
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
