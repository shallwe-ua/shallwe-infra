resource "aws_iam_group" "backend-ci" {
  name = "${local.name_prefix}-backend-iam-grp-ci"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "backend-ci-AmazonEC2ContainerRegistryFullAccess" {
  group      = aws_iam_group.backend-ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_group_policy_attachment" "backend-ci-AmazonECS_FullAccess" {
  group      = aws_iam_group.backend-ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}


resource "aws_iam_group" "global-tf" {
  name = "${local.name_prefix}-global-iam-grp-tf"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "global-tf-AdministratorAccess" {
  group      = aws_iam_group.global-tf.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
