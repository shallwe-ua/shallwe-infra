resource "aws_iam_user" "global-tf" {
  name = "${local.name_prefix}-global-iam-usr-tf"
  path = "/"
}

resource "aws_iam_user_group_membership" "global-tf" {
  user   = aws_iam_user.global-tf.name
  groups = [aws_iam_group.global-tf.name]
}

resource "aws_iam_access_key" "global-tf" {
  user   = aws_iam_user.global-tf.name
  status = "Active"
}


resource "aws_iam_user" "backend-ci" {
  name = "${local.name_prefix}-backend-iam-usr-ci"
  path = "/"
}

resource "aws_iam_user_group_membership" "backend-ci" {
  user   = aws_iam_user.backend-ci.name
  groups = [aws_iam_group.backend-ci.name]
}
