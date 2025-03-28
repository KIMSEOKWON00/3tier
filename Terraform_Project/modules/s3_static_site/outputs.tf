output "s3_bucket_name" {
  description = "정적 웹사이트 호스팅용 S3 버킷 이름"
  value       = aws_s3_bucket.static_site.bucket
}
