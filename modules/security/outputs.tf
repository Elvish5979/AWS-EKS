output "secrets_kms_key_arn" { value = aws_kms_key.secrets.arn }
output "ebs_kms_key_arn" { value = aws_kms_key.ebs.arn }
