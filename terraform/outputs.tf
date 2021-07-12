output "postgres_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "ecr_respository_endpoint" {
  value = aws_ecr_repository.container_repository.repository_url
}
