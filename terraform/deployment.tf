####### Networking ####################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.default_tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "pub_subnet" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "eu-west-2a"

  tags = var.default_tags
}

resource "aws_subnet" "pub2_subnet" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "eu-west-2b"

  tags = var.default_tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = var.default_tags
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.public.id
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


####### Autoscaling Group ####################

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json

  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name

  tags = var.default_tags
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-0d9feb0e9cd3526e4"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_security_group.id]
  user_data            = "#!/bin/bash\necho ECS_Cluster=data-collector-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "ecs-asg"
  vpc_zone_identifier  = [aws_subnet.pub_subnet.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
}


####### Database ####################

resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.pub_subnet.id, aws_subnet.pub2_subnet.id]

  tags = var.default_tags
}

resource "aws_db_instance" "postgres" {
  name                         = "DataCollectorPostgres"
  allocated_storage            = 5 # In gigabytes
  backup_retention_period      = 2
  backup_window                = "01:00-01:30"
  maintenance_window           = "sun:03:00-sun:03:30"
  multi_az                     = true
  engine                       = "postgres"
  engine_version               = "13.3"
  storage_encrypted            = true
  username                     = var.database_username
  password                     = var.database_password
  port                         = 5432
  instance_class               = "db.t3.micro"
  skip_final_snapshot          = true
  performance_insights_enabled = true
  db_subnet_group_name         = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.rds_security_group.id, aws_security_group.ecs_security_group.id]

  tags = var.default_tags
}

####### ECS ####################

resource "aws_ecr_repository" "container_repository" {
  name = "container-repository"

  tags = var.default_tags
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"

  tags = var.default_tags
}

data "template_file" "task_definition_template" {
  template = file("task_definition.json.tpl")
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
}
