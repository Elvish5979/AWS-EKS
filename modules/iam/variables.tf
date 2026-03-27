variable "name_prefix" { type = string }
variable "aws_region" { type = string }
variable "environment" { type = string }
variable "project_name" { type = string }
variable "cluster_oidc_issuer_url" {
  type    = string
  default = ""
}
