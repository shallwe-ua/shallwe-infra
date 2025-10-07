resource "aws_autoscaling_group" "backend-ec2" {
  name = "${local.name_prefix}-backend-ec2-asg"

  launch_template {
    id      = aws_launch_template.backend-ec2.id
    version = aws_launch_template.backend-ec2.latest_version
  }

  min_size         = 0
  max_size         = var.backend_desired_count
  desired_capacity = var.backend_desired_count

  health_check_grace_period = var.backend_ag_healthcheck_grace_period
  health_check_type         = "EC2"

  vpc_zone_identifier = [
    aws_subnet.main-0.id,
    aws_subnet.main-16.id,
    aws_subnet.main-32.id
  ]

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-backend-ec2-asg"
    propagate_at_launch = true
  }
}


resource "aws_ecs_capacity_provider" "backend_ec2_cp" {
  name = "${local.name_prefix}-backend-ecs-ec2-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.backend-ec2.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status = "ENABLED"
    }
  }
}
