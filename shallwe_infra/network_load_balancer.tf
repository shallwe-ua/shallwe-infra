resource "aws_lb" "main-alb" {
  name               = "${local.name_prefix}-main-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend-firewall.id]

  subnet_mapping {
    subnet_id = aws_subnet.main-0.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.main-16.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.main-32.id
  }

  enable_cross_zone_load_balancing            = true
  enable_tls_version_and_cipher_suite_headers = false
}


resource "aws_lb_listener" "main-alb" {
  load_balancer_arn = aws_lb.main-alb.arn

  default_action {
    target_group_arn = aws_lb_target_group.backend-alb.arn
    type             = "forward"
  }

  port                                 = 80
  routing_http_response_server_enabled = true
}
