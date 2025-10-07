resource "aws_iam_role" "backend-rds-monitor" {
  name               = "${local.name_prefix}-backend-iam-role-rds-monitor"
  assume_role_policy = replace(local.assume_role_policy_template, "%SERVICE%", "monitoring.rds.amazonaws.com")
}


resource "aws_iam_role_policy_attachment" "backend-rds-monitor-AmazonRDSEnhancedMonitoringRole" {
  role       = aws_iam_role.backend-rds-monitor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


resource "aws_iam_role" "backend-ec2-access" {
  name               = "${local.name_prefix}-backend-iam-role-ec2-access"
  assume_role_policy = replace(local.assume_role_policy_template, "%SERVICE%", "ec2.amazonaws.com")
}


resource "aws_iam_role_policy_attachment" "backend-ec2-access-AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.backend-ec2-access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" "backend-ec2-access-AmazonEC2ContainerServiceforEC2Role" {
  role       = aws_iam_role.backend-ec2-access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_role" "backend-ecs-task" {
  name               = "${local.name_prefix}-backend-iam-role-ecs-task"
  assume_role_policy = replace(local.assume_role_policy_template, "%SERVICE%", "ecs-tasks.amazonaws.com")
}


resource "aws_iam_role_policy_attachment" "backend-ecs-task-AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.backend-ecs-task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


locals {
  assume_role_policy_template = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "%SERVICE%" # Placeholder for the actual service
        }
      }
    ]
  })
}
