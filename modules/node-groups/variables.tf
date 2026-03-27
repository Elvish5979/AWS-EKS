variable "name_prefix" { type = string }
variable "cluster_name" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "node_role_arn" { type = string }
variable "ebs_kms_key_arn" { type = string }
variable "cluster_sg_id" { type = string }
variable "vpc_id" { type = string }

variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    ami_type       = string
    disk_size_gb   = number
    desired_size   = number
    min_size       = number
    max_size       = number
    labels         = map(string)
    taints         = list(object({ key = string, value = string, effect = string }))
  }))
}
