variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "intra_subnet_cidrs" { type = list(string) }
variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
