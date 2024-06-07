terraform {
  backend "s3" {
    bucket = "aiops-logs-bucket"
    key    = "tfstatefolder/terraform.tfstate"
    region = "us-east-1"
  }
}

module "aiops-eks-fargate-cluster" {
  source = ".//modules/aws-eks-cluster/aiopsV2"

  account_abbreviation = "ai"
  prod_non-prod        = "non-prod"
  eks_version          = "1.29"
  eks-cluster-name     = "app-cluster"
  vpc_id               = "vpc-3c60f041"
  ec2_ssh_key          = "aiopskey"
  subnet_ids           = ["eks-c-sub3", "myPublicSubnet1", "subnet-7a89ce1c", "eks-c-sub2", "subnet-12c1d65f", "subnet-f1048fc0", "eks-c-sub1"]
  fargate_profiles = {
    kube-system = {
      namespace = "kube-system"
      tags = {
        Test = "kube-system"
      }
    }
    coredns = {
      namespace = "kube-system"
      tags = {
        Test = "kube-system"
      }
    }
    aiops-app = {
      namespace = "aiops-app"
      tags = {
        Test = "aiops-app"
      }
    }
  }
}
