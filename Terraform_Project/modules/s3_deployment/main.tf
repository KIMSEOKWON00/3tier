# S3 버킷 생성
resource "aws_s3_bucket" "deployment_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

# S3 버킷 퍼블릭 액세스 차단 설정
resource "aws_s3_bucket_public_access_block" "deployment_bucket_public_access" {
  bucket = aws_s3_bucket.deployment_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
