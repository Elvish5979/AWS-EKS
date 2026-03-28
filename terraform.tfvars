project_name                         = "XX"
environment                          = "Dev"
owner                                = "Vishal"
aws_region                           = "us-east-1"
cluster_version                      = "1.29"
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
availability_zones                   = ["us-east-1a"]
vpc_cidr                             = "10.0.0.0/16"
private_subnet_cidrs                 = ["10.0.1.0/24"]
public_subnet_cidrs                  = ["10.0.101.0/24"]
intra_subnet_cidrs                   = ["10.0.201.0/24"]

node_groups = {
  dev = {
    instance_types = ["t3a.small"]
    capacity_type  = "SPOT"
    ami_type       = "AL2_x86_64"
    disk_size_gb   = 20
    desired_size   = 1
    min_size       = 1
    max_size       = 1
    labels         = { role = "dev" }
    taints         = []
  }
}

enable_cluster_autoscaler           = false
enable_aws_load_balancer_controller = false
enable_metrics_server               = false
enable_external_dns                 = false
enable_karpenter                    = false
enable_argocd                       = true