resource "aws_efs_file_system" "backend" {
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  protection {
    replication_overwrite = "ENABLED"
  }

  tags = {
    Name = "${local.name_prefix}-backend-efs"
  }
}


resource "aws_efs_access_point" "backend-static" {
  file_system_id = aws_efs_file_system.backend.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }

    path = "/app/staticfiles"
  }

  tags = {
    Name = "${local.name_prefix}-backend-efs-ap-static"
  }
}

resource "aws_efs_access_point" "backend-media" {
  file_system_id = aws_efs_file_system.backend.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }

    path = "/app/media"
  }

  tags = {
    Name = "${local.name_prefix}-backend-efs-ap-media"
  }
}
