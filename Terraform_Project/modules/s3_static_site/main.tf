# 1. S3 버킷 생성
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  tags = var.bucket_tags
}

# 2. S3 버킷에 대한 퍼블릭 접근 차단 설정
#    -> 정적 콘텐츠는 CloudFront를 통해서만 접근하도록 설정
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. S3 버킷 정책 설정
#    -> 오직 CloudFront OAI를 통해서만 S3 객체(GET 요청)가 가능하도록 제한
resource "aws_s3_bucket_policy" "static_site_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess",
        Effect    = "Allow",
        Principal = {
          AWS = var.cloudfront_oai_arn
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}
