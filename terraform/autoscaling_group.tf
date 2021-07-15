resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-0d9feb0e9cd3526e4"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  name                 = "ecs-cluster"
  security_groups      = [aws_security_group.ecs_security_group.id]
  user_data            = "#!/bin/bash\necho ECS_Cluster=ecs-cluster >> /etc/ecs/ecs.config" # Tell the ECS agent which cluster to join

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
