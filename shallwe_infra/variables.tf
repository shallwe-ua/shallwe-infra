# System-wise
variable "aws_region" {
  type        = string
  description = "AWS region for all providers/resources"
  default     = "eu-central-1"
}

variable "domain_name" {
  type        = string
  description = "Specific domain if present. ALB DNS name will be used instead if empty"
  default     = ""
}


# Backend resources
variable "backend_desired_count" {
  type        = number
  description = "Controls how many tasks and according instances should be up"
  default     = 0
}

variable "backend_ag_healthcheck_grace_period" {
  type        = number
  description = "Controls healthcheck grace period in Autoscaling group for Backend"
  default     = 120
}

variable "backend_ecs_service_healthcheck_grace_period" {
  description = "Grace period for the health check in the ECS service (in seconds)"
  type        = number
  default     = 90
}

variable "backend_container_healthcheck_grace_period" {
  description = "Optional grace period during which health check failures are ignored (in seconds)"
  type        = number
  default     = 90
}

variable "backend_container_healthcheck_interval" {
  description = "Time interval between health checks for the backend container (in seconds)"
  type        = number
  default     = 30
}

variable "backend_container_healthcheck_timeout" {
  description = "Timeout for each health check command for the backend container (in seconds)"
  type        = number
  default     = 30
}

variable "backend_container_healthcheck_retries" {
  description = "Number of consecutive health check failures allowed before the container is considered unhealthy"
  type        = number
  default     = 5
}


# Backend LB healtcheck
variable "backend_alb_tg_healthcheck_healthy_threshold" {
  description = "Number of consecutive health checks successes required for a target to be considered healthy"
  type        = number
  default     = 2
}

variable "backend_alb_tg_healthcheck_interval" {
  description = "Approximate interval between health checks for the backend ALB target group (in seconds)"
  type        = number
  default     = 30
}

variable "backend_alb_tg_healthcheck_timeout" {
  description = "Amount of time during which no response from a target means a failed health check (in seconds)"
  type        = number
  default     = 30
}

variable "backend_alb_tg_healthcheck_unhealthy_threshold" {
  description = "Number of consecutive health check failures required for a target to be considered unhealthy"
  type        = number
  default     = 8
}


# Database
variable "backend_db_1_pwd" {
  type        = string
  description = "Backend RDS PSQL-1 password"
  sensitive   = true
}


# Images
variable "image_registry_url" {
  type        = string
  description = "Docker images registry URL"
}

variable "backend_image" {
  type        = string
  description = "Backend image name:tag"
}

variable "nginx_image" {
  type        = string
  description = "Nginx image name:tag"
}


# Container environment
variable "global_use_secure_protocol" {
  type        = bool
  description = "Use HTTPS or not"
  default     = false
}

variable "global_env_mode" {
  type        = string
  description = "App environment mode"
  default     = "QA"
}

variable "global_oauth_client_id" {
  type        = string
  description = "OAuth client id"
}

variable "global_oauth_secret" {
  type        = string
  description = "OAuth client secret"
  sensitive   = true
}

variable "backend_django_secret" {
  type        = string
  description = "Django secret key"
  sensitive   = true
}

variable "backend_django_superuser" {
  type        = string
  description = "Django superuser name"
  sensitive   = true
}

variable "backend_django_superuser_email" {
  type        = string
  description = "Django superuser email"
  sensitive   = true
}

variable "backend_django_superuser_pwd" {
  type        = string
  description = "Django superuser password"
  sensitive   = true
}

variable "backend_entrypoint_workers_mult" {
  type        = string
  description = "Gunicorn workers multiplier (Total: CPU count * N + 1, this = N)"
  default     = "1"
}

variable "backend_entrypoint_workers_preload" {
  type        = string
  description = "Gunicorn workers preload mode (Might save some memory by sharing unchanged parts)"
  default     = "true"
}

variable "backend_entrypoint_workers_timeout" {
  type        = string
  description = "Gunicorn workers timeout"
  default     = "45"
}

variable "backend_django_deepface_models" {
  type        = string
  description = "Deepface models to use (Supported: ssd, mtcnn, retinaface), comma-separated"
  default     = "ssd"
}
