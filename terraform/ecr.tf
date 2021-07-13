resource "aws_ecr_repository" "container_repository" {
  name = "container-repository"

  tags = var.default_tags
}
