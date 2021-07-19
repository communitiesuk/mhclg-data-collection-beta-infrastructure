resource "aws_ecr_repository" "container_repository" {
  name = "container-repository"

  tags = var.default_tags
}


resource "aws_ecr_lifecycle_policy" "image_expiration_policy" {
  repository = aws_ecr_repository.container_repository.name

  policy = <<EOF
  {
      "rules": [
          {
              "rulePriority": 1,
              "description": "Keep latest 10 images only",
              "selection": {
                  "tagStatus": "any",
                  "countType": "imageCountMoreThan",
                  "countNumber": 10
              },
              "action": {
                  "type": "expire"
              }
          }
      ]
  }
EOF
}
