variable "cluster_name" { type = string }
variable "cluster_endpoint" { type = string }
variable "cluster_oidc_issuer_url" { type = string }
variable "cluster_ca_certificate" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "name_prefix" { type = string }
variable "oidc_provider_arn" { type = string }
variable "enable_cluster_autoscaler" {
  type    = bool
  default = true
}
variable "enable_aws_load_balancer_controller" {
  type    = bool
  default = true
}
variable "enable_metrics_server" {
  type    = bool
  default = true
}
variable "enable_external_dns" {
  type    = bool
  default = false
}
variable "hosted_zone_id" {
  type    = string
  default = ""
}

variable "enable_karpenter" {
  type    = bool
  default = false
}

variable "enable_argocd" {
  type    = bool
  default = false
}