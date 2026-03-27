data "aws_caller_identity" "current" {}

# ── KMS key: EKS Secrets encryption ──────────────────────────────────────────
resource "aws_kms_key" "secrets" {
  description             = "${var.name_prefix} — EKS secrets encryption"
  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow EKS"
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
        Action = [
          "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
          "kms:GenerateDataKey*", "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.name_prefix}-eks-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# ── KMS key: EBS volume encryption ───────────────────────────────────────────
resource "aws_kms_key" "ebs" {
  description             = "${var.name_prefix} — EKS EBS volume encryption"
  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid    = "Allow AutoScaling service role"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action = [
          "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
          "kms:GenerateDataKey*", "kms:DescribeKey", "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.name_prefix}-eks-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}

# ── Default EBS encryption ────────────────────────────────────────────────────
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}
