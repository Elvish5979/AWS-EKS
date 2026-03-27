variable "name_prefix" { type = string }
variable "aws_region" { type = string }
variable "kms_key_deletion_window_days" {
  type    = number
  default = 30
}
