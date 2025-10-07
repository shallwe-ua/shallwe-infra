resource "aws_ecs_cluster" "backend" {
  name = "${local.name_prefix}-backend-ecs-cluster"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}


resource "aws_ecs_cluster_capacity_providers" "backend" {
  cluster_name       = aws_ecs_cluster.backend.name
  capacity_providers = [aws_ecs_capacity_provider.backend_ec2_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.backend_ec2_cp.name
    base              = 0
    weight            = 1
  }
}
