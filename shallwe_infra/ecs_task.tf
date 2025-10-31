resource "aws_ecs_task_definition" "backend-ecs-task-up" {
  family                   = "${local.name_prefix}-backend-ecs-task-up"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  cpu    = 1741
  memory = 819

  execution_role_arn = aws_iam_role.backend-ecs-task.arn

  container_definitions = jsonencode([
    local.backend_backend_container_definition,
    local.backend_nginx_container_definition
  ])

  volume {
    name = "static"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.backend.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 0

      authorization_config {
        access_point_id = aws_efs_access_point.backend-static.id
      }
    }
  }

  volume {
    name = "media"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.backend.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 0

      authorization_config {
        access_point_id = aws_efs_access_point.backend-media.id
      }
    }
  }
}


# Container locals
locals {
  # Definitions
  # Backend container
  backend_backend_container_definition = {
    name      = local.backend_backend_container_name
    image     = local.backend_backend_image_url
    essential = true

    cpu               = 1321
    memory            = 614
    memoryReservation = 563

    environment = local.backend_backend_container_env

    readonlyRootFilesystem = false
    mountPoints = [
      {
        containerPath = "/app/staticfiles/"
        readOnly      = false
        sourceVolume  = "static"
      },
      {
        containerPath = "/app/media/"
        readOnly      = false
        sourceVolume  = "media"
      }
    ]

    portMappings = [
      {
        appProtocol   = "http"
        containerPort = 8000
        hostPort      = 8000
        name          = "${local.backend_backend_container_name}-port-8000"
        protocol      = "tcp"
      }
    ]

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8000/api/rest/health/health/ || exit 1"]
      interval    = var.backend_container_healthcheck_interval
      timeout     = var.backend_container_healthcheck_timeout
      retries     = var.backend_container_healthcheck_retries
      startPeriod = var.backend_container_healthcheck_grace_period
    }

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/${local.name_prefix}-backend-ecs-task-up-backend"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }

  # Nginx container
  backend_nginx_container_definition = {
    name      = local.backend_nginx_container_name
    image     = local.backend_nginx_image_url
    essential = true

    cpu               = 410
    memory            = 205
    memoryReservation = 154

    dependsOn = [
      {
        condition     = "HEALTHY"
        containerName = local.backend_backend_container_name
      }
    ]

    environment = local.backend_nginx_container_env

    readonlyRootFilesystem = false
    mountPoints = [
      {
        containerPath = "/app/staticfiles/"
        readOnly      = true
        sourceVolume  = "static"
      },
      {
        containerPath = "/app/media/"
        readOnly      = true
        sourceVolume  = "media"
      }
    ]

    portMappings = [
      {
        appProtocol   = "http"
        containerPort = 80
        hostPort      = 80
        name          = "${local.backend_nginx_container_name}-port-80"
        protocol      = "tcp"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/${local.name_prefix}-backend-ecs-task-up-nginx"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }


  # Environment variables
  # Backend variables
  backend_backend_container_env = [
    # Environment mode
    {
      name  = "SHALLWE_GLOBAL_ENV_MODE"
      value = var.global_env_mode
    },

    # Site
    {
      name  = "SHALLWE_GLOBAL_SITE_URL_EXTERNAL"
      value = local.pub_address
    },
    {
      name  = "SHALLWE_GLOBAL_SITE_URL_INTERNAL" # Points to the port on localhost (if using awsvpc) with index container running
      value = "http://localhost:8000"
    },

    # Media
    {
      name  = "SHALLWE_GLOBAL_MEDIA_STORAGE_URL_EXTERNAL"
      value = local.pub_address
    },

    # Oauth
    {
      name  = "SHALLWE_GLOBAL_OAUTH_CLIENT_ID"
      value = var.global_oauth_client_id
    },
    {
      name  = "SHALLWE_GLOBAL_OAUTH_CLIENT_SECRET"
      value = var.global_oauth_secret
    },
    {
      name  = "SHALLWE_GLOBAL_OAUTH_REDIRECT_URI"
      value = local.pub_address
    },

    # Django core
    {
      name  = "SHALLWE_BACKEND_SECRET_KEY"
      value = var.backend_django_secret
    },
    {
      name  = "SHALLWE_BACKEND_DEBUG_ON"
      value = "False"
    },
    {
      name  = "SHALLWE_BACKEND_REST_BROWSABLE"
      value = "False"
    },

    # Entrypoint
    {
      name  = "SHALLWE_BACKEND_ENTRYPOINT_AUTORUN"
      value = "true"
    },
    {
      name  = "SHALLWE_BACKEND_ENTRYPOINT_AUTOTEST"
      value = "false"
    },
    {
      name  = "SHALLWE_BACKEND_ENTRYPOINT_WORKERS_MULT"
      value = var.backend_entrypoint_workers_mult
    },
    {
      name  = "SHALLWE_BACKEND_ENTRYPOINT_WORKERS_PRELOAD"
      value = var.backend_entrypoint_workers_preload
    },
    {
      name  = "SHALLWE_BACKEND_ENTRYPOINT_WORKERS_TIMEOUT"
      value = var.backend_entrypoint_workers_timeout
    },

    # Admin
    {
      name  = "DJANGO_SUPERUSER_USERNAME"
      value = var.backend_django_superuser
    },
    {
      name  = "DJANGO_SUPERUSER_EMAIL"
      value = var.backend_django_superuser_email
    },
    {
      name  = "DJANGO_SUPERUSER_PASSWORD"
      value = var.backend_django_superuser_pwd
    },

    # Database
    {
      name  = "SHALLWE_BACKEND_DB_NAME"
      value = aws_db_instance.backend-rds-psql-1.db_name
    },
    {
      name  = "SHALLWE_BACKEND_TEST_DB_NAME"
      value = "${aws_db_instance.backend-rds-psql-1.db_name}-test"
    },
    {
      name  = "SHALLWE_BACKEND_DB_USER"
      value = aws_db_instance.backend-rds-psql-1.username
    },
    {
      name  = "SHALLWE_BACKEND_DB_PASS"
      value = var.backend_db_1_pwd
    },
    {
      name  = "SHALLWE_BACKEND_DB_HOST"
      value = aws_db_instance.backend-rds-psql-1.address
    },
    {
      name  = "SHALLWE_BACKEND_DB_PORT"
      value = aws_db_instance.backend-rds-psql-1.port
    },

    # Network
    {
      name  = "SHALLWE_BACKEND_ALLOWED_HOSTS"
      value = "localhost, 127.0.0.1, ${local.pub_domain}"
    },
    {
      name  = "SHALLWE_BACKEND_ALLOWED_CIDR_NETS"
      value = aws_vpc.main.cidr_block
    },
    {
      name  = "SHALLWE_BACKEND_CSRF_TRUSTED_ORIGINS"
      value = "http://127.0.0.1:80, ${local.pub_address}"
    },
    {
      name  = "SHALLWE_BACKEND_CORS_ALLOWED_ORIGINS"
      value = "http://127.0.0.1:80, ${local.pub_address}"
    },
    {
      name  = "SHALLWE_BACKEND_CREDENTIALS_COOKIE_DOMAIN"
      value = "${local.pub_domain}"
    },
    {
      name  = "SHALLWE_BACKEND_CREDENTIALS_COOKIE_SAMESITE"
      value = "None"
    },
    {
      name  = "SHALLWE_BACKEND_CREDENTIALS_COOKIE_SECURE"
      value = var.global_use_secure_protocol ? "True" : "False"
    },

    # Deepface
    {
      name  = "SHALLWE_BACKEND_DEEPFACE_MODELS"
      value = var.backend_django_deepface_models
    },

    # Logs
    {
      name  = "TF_CPP_MIN_LOG_LEVEL"
      value = "3"
    }
  ]

  # Nginx variables
  backend_nginx_container_env = [
    {
      name  = "NEXT_PUBLIC_SHALLWE_API_BASE_URL_INTERNAL"
      value = "http://localhost:8000"
    },
    {
      name  = "SHALLWE_GLOBAL_SITE_URL_INTERNAL"
      value = "http://localhost:8000"
    }
  ]
}
