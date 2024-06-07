output "cluster_id" {
  value = aws_eks_cluster.eks-cluster.id
}

output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "identity" {
  value = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

output "eks_worker_node_group_iam_role_arn" {
  value = length(var.node_groups) > 0 ? module.eks-node-group-roles[0].arn : null
}

output "eks_worker_node_group_iam_role_name" {
  value = length(var.node_groups) > 0 ? module.eks-node-group-roles[0].name : null
}
