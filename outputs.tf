output "vpc_id" { value = module.vpc.vpc_id }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }

output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}
output "cluster_version" {
  value = module.eks.cluster_version
}
output "oidc_issuer_url" {
  value = module.eks.oidc_issuer_url
}
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "secrets_kms_key_arn" {
  value     = module.security.secrets_kms_key_arn
  sensitive = true
}
output "ebs_kms_key_arn" {
  value     = module.security.ebs_kms_key_arn
  sensitive = true
}

output "kubeconfig_command" {
  description = "Run this to update your local kubeconfig"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "argocd_url" {
  description = "ArgoCD server LoadBalancer URL"
  value       = module.addons.argocd_url
}