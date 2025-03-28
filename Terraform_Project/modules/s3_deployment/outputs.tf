output "bucket_id" {
  description = "생성된 배포 패키지용 S3 버킷 ID"
  value       = aws_s3_bucket.deployment_bucket.id
}

output "bucket_arn" {
  description = "생성된 배포 패키지용 S3 버킷 ARN"
  value       = aws_s3_bucket.deployment_bucket.arn
}
