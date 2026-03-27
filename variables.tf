# ── Global ─────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project/org name used as a prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (prod | staging | dev)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Team or individual responsible for this infra"
  type        = string
}

# ── Networking ──────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to spread subnets across (min 3 for HA)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private (worker-node) subnets — one per AZ"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public (ALB / NAT) subnets — one per AZ"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "intra_subnet_cidrs" {
  description = "CIDRs for intra subnets (EKS control-plane ENIs — no internet)"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

# ── EKS ─────────────────────────────────────────────────────────────────────
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "cluster_endpoint_public_access" {
  description = "Whether the K8s API server is publicly accessible (set false in strict envs)"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs that may reach the public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"] # NARROW THIS to your corporate egress IPs
}

# ── Node groups ─────────────────────────────────────────────────────────────
variable "node_groups" {
  description = "Map of managed node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string # ON_DEMAND | SPOT
    ami_type       = string # AL2_x86_64 | AL2_ARM_64 | BOTTLEROCKET_x86_64 …
    disk_size_gb   = number
    desired_size   = number
    min_size       = number
    max_size       = number
    labels         = map(string)
    taints         = list(object({ key = string, value = string, effect = string }))
  }))
  default = {
    system = {
      instance_types = ["m6i.xlarge"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "AL2_x86_64"
      disk_size_gb   = 50
      desired_size   = 3
      min_size       = 3
      max_size       = 6
      labels         = { role = "system" }
      taints         = []
    }
    app = {
      instance_types = ["m6i.2xlarge", "m6a.2xlarge", "m5.2xlarge"]
      capacity_type  = "SPOT"
      ami_type       = "AL2_x86_64"
      disk_size_gb   = 100
      desired_size   = 3
      min_size       = 3
      max_size       = 20
      labels         = { role = "app" }
      taints         = []
    }
  }
}

# ── KMS ─────────────────────────────────────────────────────────────────────
variable "kms_key_deletion_window_days" {
  description = "Waiting period before KMS key deletion (7-30)"
  type        = number
  default     = 30
}

# ── Addons ──────────────────────────────────────────────────────────────────
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
  description = "Enable Karpenter node autoprovisioner (replaces Cluster Autoscaler when true)"
  type        = bool
  default     = false
}

variable "enable_argocd" {
  description = "Enable ArgoCD GitOps tool"
  type        = bool
  default     = false
}