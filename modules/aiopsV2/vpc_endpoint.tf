module "eks_vpc_endpoints" {
  source  = "./modules/vpc_endpoints"
  version = ">= 2.0.0"

  aws_account_abbreviation = local.acct_abbreviation
  vpc_id                   = var.vpc_id
  vpc_endpoints = {
    ecr_api = {
      service_name       = "com.amazonaws.us-east-1.ecr.api"
      vpc_endpoint_type  = "interface"
      security_group_ids = [module.eks-security-group-cluster.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-cluster"], module.eks-security-group-worker-node.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-worker-nodes"]]
    }
    ecr_dkr = {
      service_name       = "com.amazonaws.us-east-1.ecr.dkr"
      vpc_endpoint_type  = "interface"
      security_group_ids = [module.eks-security-group-cluster.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-cluster"], module.eks-security-group-worker-node.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-worker-nodes"]]
    }
  }
}
