ata "aws_region" "current" {}

resource "aws_vpc_endpoint" "endpoints" {
  for_each = var.vpc_endpoints

  vpc_id              = var.vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = title(each.value.vpc_endpoint_type)
  private_dns_enabled = lookup(each.value, "private_dns_enabled", null)
  security_group_ids  = lookup(each.value, "security_group_ids", null)
  route_table_ids     = lookup(each.value, "route_table_ids", null)
  subnet_ids          = lookup(each.value, "subnet_ids", null)
  policy              = lookup(each.value, "policy", null)

  tags = merge(
    {
      Name = "${var.aws_account_abbreviation}-${data.aws_region.current.name}-vpc-endpoint-${each.key}"
    },
    var.tags
  )
}
