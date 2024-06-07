locals {
  acct_abbreviation = lower(var.account_abbreviation)
}

resource "aws_iam_role" "role" {
  name                  = "${local.acct_abbreviation}-iam_role-${var.name}"
  assume_role_policy    = var.assume_role_policy
  force_detach_policies = var.force_detach_policies
  path                  = var.path
  description           = var.description
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary
  tags = merge(
    {
      Name = "${local.acct_abbreviation}-iam_role-${var.name}"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "roles" {
  for_each   = var.role_policy_arns
  role       = aws_iam_role.role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ec2-role" {
  count = var.instance_profile ? 1 : 0

  name = "${local.acct_abbreviation}-iam_role-${var.name}"
  role = aws_iam_role.role.name
}
