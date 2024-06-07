locals {
  acct_abbreviation = lower(var.account_abbreviation)
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
