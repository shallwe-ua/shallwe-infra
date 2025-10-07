locals {
  # --- System-wise ---
  project     = "shallwe"
  env         = "qa"
  name_prefix = "${local.project}-${local.env}"

  default_tags = {
    Project     = local.project
    Environment = local.env
    ManagedBy   = "terraform"
  }

  # --- Network ---
  pub_protocol = var.global_use_secure_protocol ? "https://" : "http://"
  pub_domain   = length(var.domain_name) > 0 ? var.domain_name : aws_lb.main-alb.dns_name # We'll use ALB DNS as domain name if not provided
  pub_address  = "${local.pub_protocol}${local.pub_domain}"

  # --- ECS Settings ---
  backend_backend_container_name = "${local.name_prefix}-backend-ecs-backend-container"
  backend_nginx_container_name   = "${local.name_prefix}-backend-ecs-nginx-container"
  backend_backend_image_url      = "${var.image_registry_url}${var.backend_image}"
  backend_nginx_image_url        = "${var.image_registry_url}${var.nginx_image}"
}
