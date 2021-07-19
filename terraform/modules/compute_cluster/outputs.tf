output "ecs_security_group" {
  value = aws_security_group.ecs_security_group
  description = "ECS Cluster Security Group"
}

output "aws_alb_dns" {
  value = aws_alb.alb.dns_name
}
