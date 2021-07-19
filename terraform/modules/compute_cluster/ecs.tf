resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"

  tags = var.default_tags
}

data "template_file" "task_definition_template" {
  template = file("${path.module}/task_definition.json")
  vars = {
    REPOSITORY_URL           = replace(aws_ecr_repository.container_repository.repository_url, "https://", "")
    DB_HOST                  = replace(var.rds_postgres_endpoint, ":5432", "")
    DB_DATABASE              = var.database_name
    DB_USERNAME              = var.database_username
    DB_PASSWORD              = var.database_password
    RAILS_MASTER_KEY         = var.rails_master_key
    RAILS_ENV                = "production"
    RAILS_LOG_TO_STDOUT      = var.rails_log_to_stdout
    RAILS_SERVE_STATIC_FILES = var.rails_serve_static_files
  }
}

# TODO this actually isn't great because we try to create the task definition once here
# (with latest image which won't exist) and then straight away again in the build pipeline
# with the actual image tag. We should just do it once if possible.
resource "aws_ecs_task_definition" "task_definition" {
  family                = "app"
  container_definitions = data.template_file.task_definition_template.rendered
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    container_name   = "app"
    container_port   = 8080
  }

  depends_on = [
    aws_alb_listener.alb_listener
  ]
}
