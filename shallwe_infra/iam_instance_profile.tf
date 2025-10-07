resource "aws_iam_instance_profile" "backend-ec2-access" {
  name = "${local.name_prefix}-backend-iam-instance-profile-ec2-access"
  role = aws_iam_role.backend-ec2-access.name
  path = "/"
}
