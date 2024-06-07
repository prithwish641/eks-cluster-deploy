data "aws_region" "current" {}
locals {
  acct_abbreviation = lower(var.aws_account_abbreviation)
}

resource "aws_security_group" "dynamic" {
  for_each = var.security_groups
  name     = "${local.acct_abbreviation}-${data.aws_region.current.name}-sg-${each.key}"
  vpc_id   = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      from_port       = ingress.value["from_port"]
      to_port         = ingress.value["to_port"]
      protocol        = ingress.value["protocol"]
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      self            = lookup(ingress.value, "self", null)
      description     = lookup(ingress.value, "description", null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${local.acct_abbreviation}-${data.aws_region.current.name}-sg-${each.key}"
    },
    var.tags
  )
}
