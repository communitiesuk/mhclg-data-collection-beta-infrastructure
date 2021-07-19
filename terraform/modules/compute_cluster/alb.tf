resource "aws_alb_target_group" "alb_target_group" {
  name     = "alb-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.aws_vpc.id

  tags = var.default_tags
}

resource "aws_alb" "alb" {
  name            = "alb"
  subnets         = var.aws_pub_subnet.*.id
  security_groups = [aws_security_group.lb_security_group.id]

  tags = var.default_tags
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    type             = "forward"
  }
}
