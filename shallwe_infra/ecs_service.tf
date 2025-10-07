resource "aws_ecs_service" "backend" {
  name            = "${local.name_prefix}-backend-ecs-service"
  task_definition = aws_ecs_task_definition.backend-ecs-task-up.arn
  cluster         = aws_ecs_cluster.backend.id

  desired_count       = var.backend_desired_count
  scheduling_strategy = "REPLICA"

  health_check_grace_period_seconds  = var.backend_ecs_service_healthcheck_grace_period
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    base              = 0
    capacity_provider = aws_ecs_capacity_provider.backend_ec2_cp.name
    weight            = 1
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    security_groups = [aws_security_group.backend-firewall.id]
    subnets = [
      aws_subnet.main-0.id,
      aws_subnet.main-16.id,
      aws_subnet.main-32.id
    ]
  }

  load_balancer {
    container_name   = local.backend_nginx_container_name
    container_port   = 80
    target_group_arn = aws_lb_target_group.backend-alb.arn
  }

  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }

  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }

  enable_ecs_managed_tags = true
  enable_execute_command  = false
}
