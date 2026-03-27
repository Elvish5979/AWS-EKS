output "node_group_arns" {
  value = { for k, v in aws_eks_node_group.this : k => v.arn }
}

output "node_group_statuses" {
  value = { for k, v in aws_eks_node_group.this : k => v.status }
}
