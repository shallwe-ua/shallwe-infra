resource "aws_lb_target_group" "backend-alb" {
  name        = "${local.name_prefix}-backend-alb-tg"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  port     = 80
  protocol = "HTTP"

  health_check {
    path                = "/api/rest/health/health/"
    healthy_threshold   = var.backend_alb_tg_healthcheck_healthy_threshold
    interval            = var.backend_alb_tg_healthcheck_interval
    timeout             = var.backend_alb_tg_healthcheck_timeout
    unhealthy_threshold = var.backend_alb_tg_healthcheck_unhealthy_threshold
  }
}
