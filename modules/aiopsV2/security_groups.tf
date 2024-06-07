locals {
  local_subnets = [
    "172.31.32.0/20",
    "172.31.96.0/20",
    "172.31.0.0/20",
    "172.31.80.0/20",
    "172.31.16.0/20",
    "172.31.48.0/20",
    "172.31.64.0/20"
  ]
  cluster_ingress = {
    self = {
      from_port = 0
      protocol  = "-1"
      to_port   = 0
      self      = true
    }
    workers_sg = {
      from_port       = 0
      protocol        = "-1"
      to_port         = 0
      security_groups = module.eks-security-group-worker-node.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-worker-nodes"]
    }
    https = {
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
      cidr_blocks = local.local_subnets
    }
  }
  worker_ingress = {
    self = {
      from_port = 0
      protocol  = "-1"
      to_port   = 0
      self      = true
    }
    cluster_sg = {
      from_port       = 0
      protocol        = "-1"
      to_port         = 0
      security_groups = module.eks-security-group-cluster.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-cluster"]
    }
    all_ports = {
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      cidr_blocks = local.local_subnets
    }
  }
}

module "eks-security-group-cluster" {
  source  = "./modules/security_groups"
  version = ">= 2.0.0"

  aws_account_abbreviation = local.acct_abbreviation
  vpc_id                   = var.vpc_id
  security_groups = {
    aiops-eks-cluster = {
      ingress_rules = []
    }
  }
}

module "eks-security-group-worker-node" {
  source  = "./modules/security_groups"
  version = ">= 2.0.0"

  aws_account_abbreviation = local.acct_abbreviation
  vpc_id                   = var.vpc_id
  security_groups = {
    aiops-eks-worker-nodes = {
      ingress_rules = []
    }
  }
  tags = {
    "kubernetes.io/cluster/${local.acct_abbreviation}-${data.aws_region.current.name}-aiops-eks-cluster" = "owned"
  }
}

resource "aws_security_group_rule" "cluster_ingress" {
  for_each = local.cluster_ingress

  protocol                 = each.value.protocol
  security_group_id        = module.eks-security-group-cluster.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-cluster"]
  source_security_group_id = try(each.value.security_groups, null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = "ingress"
  cidr_blocks              = try(each.value.cidr_blocks, null)
  self                     = try(each.value.self, null)
}

resource "aws_security_group_rule" "worker_ingress" {
  for_each = local.worker_ingress

  protocol                 = each.value.protocol
  security_group_id        = module.eks-security-group-worker-node.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-worker-nodes"]
  source_security_group_id = try(each.value.security_groups, null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = "ingress"
  cidr_blocks              = try(each.value.cidr_blocks, null)
  self                     = try(each.value.self, null)
}
