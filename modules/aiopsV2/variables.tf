variable "account_abbreviation" {
  type = string
  validation {
    condition     = length(var.account_abbreviation) == 3
    error_message = "Abbreviation must be 3 letters max."
  }
  description = "3 letter aws account abbreviation"
}

variable "prod_non-prod" {
  type = string
  validation {
    condition     = var.prod_non-prod == "prod" || var.prod_non-prod == "non-prod"
    error_message = "Value should be either prod or non-prod."
  }
  description = "Is this system a prod or non-prod system"
}

variable "eks-cluster-name" {
  description = "Define the EKS cluster name"
  type        = string
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for endpoints"
}

variable "eks_encryption_key" {
  type        = string
  description = "KMS encryption key for eks secrets and managed nodes ebs volume encryption"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for worker nodes or fargate profiles"
}

variable "eks_version" {
  type        = string
  description = "Version of EKS management cluster and worker nodes to deploy"
}

variable "ec2_ssh_key" {
  type        = string
  default     = null
  description = "ssh key for ec2 worker nodes"
}

variable "node_groups" {
  type        = map(any)
  default     = {}
  description = "Map of 1 or more node group configurations"
}

variable "fargate_profiles" {
  type        = map(any)
  default     = {}
  description = "Map of 1 or more fargate profile configurations"
}

variable "map_accounts" {
  type        = list(string)
  default     = []
  description = "Additional AWS account numbers to add to the aws-auth configmap"
}

variable "map_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "Additional IAM roles to add to the aws-auth configmap"
}

variable "map_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "Additional IAM users to add to the aws-auth configmap"
}
