data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20210708-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    cluster_name = resource.aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_key_pair" "ecs_key_pair" {
  key_name   = "ecs-key-pair"
  public_key = var.public_ssh
  tags       = var.default_tags
}

resource "aws_launch_configuration" "ecs_launch_config" {
  name                        = "ecs-launch-config"
  key_name                    = aws_key_pair.ecs_key_pair.key_name
  image_id                    = data.aws_ami.ecs_optimized.id
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  security_groups             = [aws_security_group.ecs_security_group.id]
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = true

  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "ecs-asg"
  vpc_zone_identifier  = var.aws_pub_subnet.*.id
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
}
