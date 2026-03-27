output "cluster_autoscaler_role_arn" {
  value = try(aws_iam_role.cluster_autoscaler[0].arn, "")
}
output "alb_controller_role_arn" {
  value = try(aws_iam_role.alb_controller[0].arn, "")
}
output "external_dns_role_arn" {
  value = try(aws_iam_role.external_dns[0].arn, "")
}
output "karpenter_controller_role_arn" {
  value = try(aws_iam_role.karpenter_controller[0].arn, "")
}

output "argocd_url" {
  description = "ArgoCD server LoadBalancer URL"
  value       = try("https://${data.aws_lb.argocd[0].dns_name}", "")
}