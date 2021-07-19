resource "aws_security_group" "rds_security_group" {
  name        = "rds-sg"
  description = "RDS Security Group"
  vpc_id      = var.aws_vpc.id
  tags        = var.default_tags

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # TODO limit this to just ECS IP range
    cidr_blocks     = ["0.0.0.0/0"]
    #security_groups = [var.ecs_security_group.id]
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
