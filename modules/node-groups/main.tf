# ── Launch template (one per node group for custom EBS encryption) ────────────
resource "aws_launch_template" "this" {
  for_each = var.node_groups

  name_prefix = "${var.name_prefix}-${each.key}-"
  description = "Launch template for ${each.key} node group"

  # Harden metadata endpoint: require IMDSv2, limit hop count
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1          # prevent container escape
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.disk_size_gb
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.ebs_kms_key_arn
      delete_on_termination = true
    }
  }

  # Node-hardening user-data (AL2)
  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -o errexit
    # Disable unused filesystems
    for fs in cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat; do
      echo "install $fs /bin/true" >> /etc/modprobe.d/cis.conf
    done
    # Ensure auditd is running
    systemctl enable auditd && systemctl start auditd
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "${var.name_prefix}-${each.key}-node"
      NodeGroup = each.key
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = { Name = "${var.name_prefix}-${each.key}-ebs" }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Managed Node Groups ───────────────────────────────────────────────────────
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = var.cluster_name
  node_group_name = "${var.name_prefix}-${each.key}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids # worker nodes NEVER in public subnets

  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable_percentage = 33 # rolling update: ~1/3 at a time
  }

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = aws_launch_template.this[each.key].latest_version
  }

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  labels = each.value.labels

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size] # let CA/Karpenter manage desired
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}
