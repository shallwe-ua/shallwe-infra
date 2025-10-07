resource "aws_efs_mount_target" "backend-1" {
  file_system_id  = aws_efs_file_system.backend.id
  security_groups = [aws_security_group.backend-efs.id]
  subnet_id       = aws_subnet.main-0.id
}

resource "aws_efs_mount_target" "backend-2" {
  file_system_id  = aws_efs_file_system.backend.id
  security_groups = [aws_security_group.backend-efs.id]
  subnet_id       = aws_subnet.main-16.id
}

resource "aws_efs_mount_target" "backend-3" {
  file_system_id  = aws_efs_file_system.backend.id
  security_groups = [aws_security_group.backend-efs.id]
  subnet_id       = aws_subnet.main-32.id
}
