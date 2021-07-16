output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "ecr_respository_endpoint" {
  value = aws_ecr_repository.container_repository.repository_url
}

output "ecs_task_definition" {
  value = aws_ecs_task_definition.task_definition.arn
}

output "aws_alb_dns" {
  value = aws_alb.alb.dns_name
}
