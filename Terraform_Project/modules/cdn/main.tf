# 현재 AWS 리전 정보 조회
data "aws_region" "current" {}

# CloudFront Origin Access Identity (OAI) 생성
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for React Static Site"
}

# CloudFront 배포 (CDN) 생성
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object

  # 오리진 설정: S3 REST API 엔드포인트 사용 (웹사이트 엔드포인트가 아님)
  origin {
    domain_name = "${var.s3_bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com"
    origin_id   = "S3-${var.s3_bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  # 기본 캐시 동작 설정
  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # 커스텀 에러 응답 설정 (403, 404 에러 발생 시 index.html 반환)
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/${var.default_root_object}"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${var.default_root_object}"
    error_caching_min_ttl = 0
  }

  # 기본 CloudFront 인증서 사용
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # 지역 제한 (제한 없음)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "React Static Site CDN"
  }
}
