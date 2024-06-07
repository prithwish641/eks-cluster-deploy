module "eks-node-group-roles" {
  source  = "./modules/iam_roles"
  count   = length(var.node_groups) > 0 ? 1 : 0

  account_abbreviation = local.acct_abbreviation
  name                 = "${var.eks-cluster-name}-worker-managed-node-groups-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          },
          Action = "sts:AssumeRole"
        }
      ]
    }
  )
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_launch_template" "default" {
  for_each = var.node_groups

  name                   = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-worker-lt-mng-${each.key}-${random_pet.launch_template[each.key].id}"
  description            = "EKS Launch-Template for node group ${each.key}"
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = var.eks_encryption_key
      volume_size           = 30
      volume_type           = "gp3"
    }
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  ebs_optimized = true
  key_name      = var.ec2_ssh_key
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [module.eks-security-group-worker-node.sg_ids["${local.acct_abbreviation}-${data.aws_region.current.name}-sg-aiops-eks-worker-nodes"]]
  }
  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-worker-mng-${each.key}"
      project     = each.value["project"]
    }
  }
  # Supplying custom tags to EKS instances root volumes is another use-case for LaunchTemplates. (doesnt add tags to dynamically provisioned volumes via PVC tho)
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-worker-mng-${each.key}}"
    }
  }
  # Tag the LT itself
  tags = {
    Name = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-worker-lt-mng-${each.key}-${random_pet.launch_template[each.key].id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "workers" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-mng-${each.key}-${random_pet.node_groups[each.key].id}"
  node_role_arn   = module.eks-node-group-roles[0].arn
  scaling_config {
    desired_size = each.value["desired_capacity"]
    max_size     = each.value["max_capacity"]
    min_size     = each.value["min_capacity"]
  }
  subnet_ids           = var.subnet_ids
  ami_type             = lookup(each.value, "ami_type", null)
  capacity_type        = lookup(each.value, "capacity_type", null)
  force_update_version = true
  instance_types       = try(each.value.instance_types, ["t3a.medium"])
  labels               = try(each.value.labels, null)
  launch_template {
    id      = aws_launch_template.default[each.key].id
    version = aws_launch_template.default[each.key].latest_version
  }
  release_version = lookup(each.value, "ami_release_version", null)
  tags = merge(
    {
      Name = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-mng-${each.key}-${random_pet.node_groups[each.key].id}"
    },
    try(each.value.additional_tags, {}),
  )
  version = lookup(each.value, "version", null)
  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "node_groups" {
  for_each = var.node_groups

  length = 1
  keepers = {
    ami_type        = lookup(each.value, "ami_type", null)
    capacity_type   = lookup(each.value, "capacity_type", null)
    instance_types  = join("|", compact(try(each.value.instance_types, ["t3a.medium"])))
    node_group_name = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-mng-${each.key}"
    node_role_arn   = module.eks-node-group-roles[0].arn
    launch_template = aws_launch_template.default[each.key].id
  }
}

resource "random_pet" "launch_template" {
  for_each = var.node_groups

  length = 1
  keepers = {
    lt_name = "${local.acct_abbreviation}-${data.aws_region.current.name}-eks-worker-lt-mng-${each.key}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

