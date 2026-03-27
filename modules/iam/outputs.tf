output "cluster_role_arn" { value = aws_iam_role.cluster.arn }
output "node_role_arn" { value = aws_iam_role.node.arn }
output "oidc_provider_arn" {
  value = length(aws_iam_openid_connect_provider.eks) > 0 ? aws_iam_openid_connect_provider.eks[0].arn : ""
}
output "oidc_provider_url" {
  value = length(aws_iam_openid_connect_provider.eks) > 0 ? aws_iam_openid_connect_provider.eks[0].url : ""
}
