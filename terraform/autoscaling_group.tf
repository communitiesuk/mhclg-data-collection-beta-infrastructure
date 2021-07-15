data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["591542846629"] # AWS

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }
}

data "template_file" "ecs_instance_boot_data" {
  template = file("ecs_instance_boot_data.yml")

  vars = {
    cluster_name = "ecs-cluster"
  }
}

resource "aws_launch_configuration" "ecs_launch_config" {
  name                 = "ecs-ecs_launch_config"
  image_id             = data.aws_ami.ecs_optimized.id
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.ecs_security_group.id]
  user_data            = data.template_file.ecs_instance_boot_data.rendered

  instance_type = "t2.micro"
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
