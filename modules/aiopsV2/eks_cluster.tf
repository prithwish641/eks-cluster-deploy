module "eks-cluster-role" {
  source = "./modules/iam_roles"

  account_abbreviation = local.acct_abbreviation
  name                 = "${var.eks-cluster-name}-role"
  assume_role_policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "${local.acct_abbreviation}-${data.aws_region.current.name}-${var.eks-cluster-name}"
  role_arn = module.eks-cluster-role.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [module.eks-security-group-cluster.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-ami-gvt-eks-cluster"]]
    subnet_ids              = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  version = var.eks_version

  depends_on = [
    module.eks-cluster-role
  ]
}
