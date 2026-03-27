variable "name_prefix" { type = string }
variable "cluster_version" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "intra_subnet_ids" { type = list(string) }
variable "cluster_endpoint_public_access" { type = bool }
variable "cluster_endpoint_public_access_cidrs" { type = list(string) }
variable "secrets_kms_key_arn" { type = string }
variable "cluster_role_arn" { type = string }
variable "aws_region" { type = string }
variable "oidc_provider_arn" {
  type    = string
  default = ""
}
variable "admin_role_arns" {
  type    = list(string)
  default = []
}
