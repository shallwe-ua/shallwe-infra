resource "aws_launch_template" "backend-ec2" {
  name          = "${local.name_prefix}-backend-ec2-lt"
  instance_type = "t3.micro"
  image_id      = data.aws_ami.amazon-linux-2023-ecs.id

  iam_instance_profile {
    arn = aws_iam_instance_profile.backend-ec2-access.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    device_index                = 0
    security_groups             = [aws_security_group.backend-firewall.id]
  }

  user_data = base64encode(templatefile("${path.module}/templates/backend/ec2/user_data.sh", {
    SHALLWE_AWS_BACKEND_ECS_CLUSTER_NAME = aws_ecs_cluster.backend.name
    SHALLWE_AWS_REGION                   = var.aws_region
  }))
}


data "aws_ami" "amazon-linux-2023-ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
