module "eks-fargate-profile-roles" {
  source  = "./modules/iam_roles"
  count   = length(var.fargate_profiles) > 0 ? 1 : 0

  account_abbreviation = local.acct_abbreviation
  name                 = "${var.eks-cluster-name}-fargate-profiles-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "eks-fargate-pods.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        }
      ]
    }
  )
  role_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]
}

resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles

  cluster_name           = aws_eks_cluster.eks-cluster.name
  fargate_profile_name   = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-fps-${each.key}"
  pod_execution_role_arn = module.eks-fargate-profile-roles[0].arn
  selector {
    namespace = each.value.namespace
    labels    = try(each.value.labels, null)
  }
  subnet_ids = var.subnet_ids
  tags       = try(each.value.tags, null)
}
