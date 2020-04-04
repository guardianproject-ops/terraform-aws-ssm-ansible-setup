output "playbooks_bucket_id" {
  value = aws_s3_bucket.playbooks_bucket.id
}

output "ssm_logs_bucket" {
  value = aws_s3_bucket.ssm_logs_bucket.id
}
