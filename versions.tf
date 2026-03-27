terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # ── Remote state (S3 + DynamoDB locking) ──────────────────────────────────
  # Uncomment and populate before first `terraform init`
  # backend "s3" {
  #   bucket         = "my-org-terraform-state"
  #   key            = "eks/prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  #   kms_key_id     = "alias/terraform-state"
  # }
}
