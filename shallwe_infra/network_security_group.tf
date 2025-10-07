# ----- Main security group (ECS, EC2, Netwrork) -----
resource "aws_security_group" "backend-firewall" {
  name        = "${local.name_prefix}-backend-sg-firewall"
  description = "Allows necessary traffic for backend"
  vpc_id      = aws_vpc.main.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "For registry pulling and possible other resources attached later"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = false
  }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    self      = true
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "For access from Frontend, Postman and local Dev machines"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = false
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    self      = true
  }
}

resource "aws_security_group_rule" "backend-firewall-to-backend-efs" {
  source_security_group_id = aws_security_group.backend-efs.id
  security_group_id = aws_security_group.backend-firewall.id
  type              = "egress"
  description       = "For EFS"

  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
}

resource "aws_security_group_rule" "backend-firewall-to-backend-rds-psql" {
  source_security_group_id = aws_security_group.backend-rds-psql.id
  security_group_id = aws_security_group.backend-firewall.id
  type              = "egress"
  description       = "For RDS PSQL"

  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
}


# ----- EFS security group -----
resource "aws_security_group" "backend-efs" {
  name        = "${local.name_prefix}-backend-sg-efs"
  description = "Allows EFS access from ECS"
  vpc_id      = aws_vpc.main.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = false
  }
}

resource "aws_security_group_rule" "backend-efs-from-backend-firewall" {
  source_security_group_id = aws_security_group.backend-rds-psql.id
  security_group_id = aws_security_group.backend-firewall.id
  type              = "ingress"
  description       = "Allow EFS access from ECS (backend-firewall)"

  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
}


# ----- RDS security group -----
resource "aws_security_group" "backend-rds-psql" {
  name        = "${local.name_prefix}-backend-sg-rds-psql"
  description = "Allow PostgreSQL access from ECS"
  vpc_id      = aws_vpc.main.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = false
  }
}

resource "aws_security_group_rule" "backend-rds-psql-from-backend-firewall" {
  source_security_group_id = aws_security_group.backend-rds-psql.id
  security_group_id = aws_security_group.backend-firewall.id
  type              = "ingress"
  description       = "Allow PostgreSQL access from ECS (backend-firewall)"

  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
}
