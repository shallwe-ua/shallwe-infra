resource "aws_db_instance" "backend-rds-psql-1" {
  identifier     = "${local.name_prefix}-backend-rds-psql-1"
  engine         = "postgres"
  engine_version = "16.9"

  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = local.name_prefix
  username = "postgres"
  password = var.backend_db_1_pwd

  maintenance_window         = "wed:22:23-wed:22:53"
  auto_minor_version_upgrade = false

  backup_window           = "02:12-02:42"
  backup_retention_period = 1

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-backend-rds-psql-1-snapshot-final-${replace(time_static.rds_final.rfc3339, "/[^0-9]/", "")}"

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  db_subnet_group_name   = aws_db_subnet_group.backend-rds.name
  vpc_security_group_ids = [aws_security_group.backend-rds-psql.id]
}

resource "time_static" "rds_final" {}


resource "aws_db_subnet_group" "backend-rds" {
  description = "Shallwe UA DB subnet group"
  name        = "${local.name_prefix}-backend-rds-subnet-grp"
  subnet_ids = [
    aws_subnet.main-0.id,
    aws_subnet.main-16.id,
    aws_subnet.main-32.id
  ]
}
