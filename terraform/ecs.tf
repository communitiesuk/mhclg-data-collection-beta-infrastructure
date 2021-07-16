resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"

  tags = var.default_tags
}

data "template_file" "task_definition_template" {
  template = file("task_definition.json")
  vars = {
    REPOSITORY_URL = replace(aws_ecr_repository.container_repository.repository_url, "https://", "")
  }
}

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
