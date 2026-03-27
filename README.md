# Production-Ready EKS Cluster — Terraform

Zero-security-bridge EKS setup following AWS and CIS best practices.

## Architecture

```
                          ┌─────────────────────────────────┐
                          │           AWS Account            │
                          │                                  │
                          │  ┌─────────────────────────┐    │
                          │  │          VPC             │    │
                          │  │                          │    │
                          │  │  Public Subnets (x3)     │    │
                          │  │  └─ NAT Gateways         │    │
                          │  │  └─ ALBs only             │    │
                          │  │                          │    │
                          │  │  Private Subnets (x3)    │    │
                          │  │  └─ Worker Nodes          │    │
                          │  │  └─ No public IPs         │    │
                          │  │                          │    │
                          │  │  Intra Subnets (x3)      │    │
                          │  │  └─ EKS Control Plane    │    │
                          │  │     ENIs (no internet)   │    │
                          │  └─────────────────────────┘    │
                          │                                  │
                          │  KMS Keys: secrets + EBS         │
                          │  VPC Endpoints: EC2, ECR, SSM…   │
                          │  VPC Flow Logs → CloudWatch      │
                          └─────────────────────────────────┘
```

## Security Controls

| Layer | Control |
|---|---|
| Network | Nodes in private subnets only, 1 NAT GW per AZ, VPC endpoints, flow logs |
| API Server | Private endpoint always enabled, public endpoint CIDR-restricted |
| Encryption | Secrets encrypted at rest (KMS), all EBS volumes encrypted (KMS), key rotation on |
| Nodes | IMDSv2-only (`http_tokens=required`), hop limit=1, no SSH/bastion (SSM) |
| IAM | Least-privilege roles, IRSA for all controllers, no wildcard `*` actions on nodes |
| Access | EKS Access Entries API (no manual aws-auth patching) |
| Logging | All 5 control-plane log types, 90-day CloudWatch retention |

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with admin credentials
- `kubectl` installed
- `helm` >= 3.x installed

## Step 1 — Bootstrap Remote State (one-time)

```bash
# S3 bucket
aws s3api create-bucket \
  --bucket my-org-tf-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket my-org-tf-state \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket my-org-tf-state \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block \
  --bucket my-org-tf-state \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# DynamoDB lock table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

Then uncomment the `backend "s3"` block in `versions.tf`.

## Step 2 — Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — at minimum set:
#   project_name, owner, cluster_endpoint_public_access_cidrs
```

## Step 3 — Init

```bash
terraform init
```

## Step 4 — Apply in Stages

```bash
# Stage 1: VPC + KMS
terraform apply -target=module.vpc -target=module.security -auto-approve

# Stage 2: IAM (base roles — OIDC provider created after cluster)
terraform apply -target=module.iam -auto-approve

# Stage 3: EKS control plane
terraform apply -target=module.eks -auto-approve

# Stage 4: Node groups
terraform apply -target=module.node_groups -auto-approve

# Stage 5: Add-ons + remaining resources
terraform apply -auto-approve
```

## Step 5 — Connect kubectl

```bash
aws eks update-kubeconfig \
  --name $(terraform output -raw cluster_name) \
  --region us-east-1

kubectl get nodes -o wide
```

## Step 6 — Post-Deploy Hardening

```bash
# Apply Pod Security Standards (restrict namespace)
kubectl label namespace default \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/warn=restricted

# Default-deny NetworkPolicy per namespace
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
EOF

# Verify secrets encryption
aws eks describe-cluster \
  --name $(terraform output -raw cluster_name) \
  --query 'cluster.encryptionConfig'

# Verify no nodes have public IPs
kubectl get nodes -o jsonpath='{.items[*].status.addresses}' | jq .
```

## Module Reference

| Module | Purpose |
|---|---|
| `modules/vpc` | VPC, subnets (public/private/intra), NAT GWs, route tables, VPC endpoints, flow logs |
| `modules/security` | KMS keys for secrets and EBS, account-level EBS default encryption |
| `modules/iam` | EKS cluster role, node role, OIDC provider for IRSA |
| `modules/eks` | EKS control plane, managed add-ons (vpc-cni, coredns, kube-proxy, ebs-csi), security groups, access entries |
| `modules/node-groups` | Managed node groups with hardened launch templates (IMDSv2, encrypted EBS) |
| `modules/addons` | Cluster Autoscaler, AWS Load Balancer Controller, Metrics Server, ExternalDNS, Karpenter |

## Destroy

```bash
# Remove add-ons first (Helm releases)
terraform destroy -target=module.addons -auto-approve
terraform destroy -auto-approve
```
