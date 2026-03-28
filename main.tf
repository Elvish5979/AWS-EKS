# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  Production-Ready EKS Cluster                                           ║
# ║  Security posture: zero public node access, encrypted secrets,          ║
# ║  private API endpoint option, least-privilege IAM, no wildcard S3.      ║
# ╚══════════════════════════════════════════════════════════════════════════╝



# ── 1. VPC ───────────────────────────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  intra_subnet_cidrs   = var.intra_subnet_cidrs
  project_name         = var.project_name
  environment          = var.environment
}

# ── 2. KMS keys ──────────────────────────────────────────────────────────────
module "security" {
  source = "./modules/security"

  name_prefix                  = local.name_prefix
  aws_region                   = var.aws_region
  kms_key_deletion_window_days = var.kms_key_deletion_window_days
}

# ── 3. IAM roles ─────────────────────────────────────────────────────────────
module "iam" {
  source = "./modules/iam"

  name_prefix  = local.name_prefix
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
}

# ── 4. EKS control plane ─────────────────────────────────────────────────────
module "eks" {
  source = "./modules/eks"

  name_prefix                          = local.name_prefix
  cluster_version                      = var.cluster_version
  vpc_id                               = module.vpc.vpc_id
  private_subnet_ids                   = module.vpc.private_subnet_ids
  intra_subnet_ids                     = module.vpc.intra_subnet_ids
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  secrets_kms_key_arn                  = module.security.secrets_kms_key_arn
  cluster_role_arn                     = module.iam.cluster_role_arn
  oidc_provider_arn                    = module.iam.oidc_provider_arn
  aws_region                           = var.aws_region
}

# ── 5. Managed node groups ───────────────────────────────────────────────────
module "node_groups" {
  source = "./modules/node-groups"

  name_prefix        = local.name_prefix
  cluster_name       = module.eks.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  node_role_arn      = module.iam.node_role_arn
  node_groups        = var.node_groups
  ebs_kms_key_arn    = module.security.ebs_kms_key_arn
  cluster_sg_id      = module.eks.cluster_security_group_id
  vpc_id             = module.vpc.vpc_id

  depends_on = [module.eks]
}

# ── 6. EKS add-ons & Helm charts ─────────────────────────────────────────────
module "addons" {
  source = "./modules/addons"

  cluster_name                        = module.eks.cluster_name
  cluster_endpoint                    = module.eks.cluster_endpoint
  cluster_oidc_issuer_url             = module.eks.oidc_issuer_url
  cluster_ca_certificate              = module.eks.cluster_ca_certificate
  aws_region                          = var.aws_region
  vpc_id                              = module.vpc.vpc_id
  name_prefix                         = local.name_prefix
  enable_cluster_autoscaler           = var.enable_cluster_autoscaler && !var.enable_karpenter
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_metrics_server               = var.enable_metrics_server
  enable_external_dns                 = var.enable_external_dns
  hosted_zone_id                      = var.hosted_zone_id
  enable_karpenter                    = var.enable_karpenter
  oidc_provider_arn                   = module.iam.oidc_provider_arn
  enable_argocd                       = var.enable_argocd

  depends_on = [module.node_groups]
}
