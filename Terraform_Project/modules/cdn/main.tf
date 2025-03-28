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
  comment             = "CloudFront Distribution for Static Content and API"
  default_root_object = var.default_root_object

  # 오리진 설정: 졍젹컨텐츠 제공, S3 REST API 엔드포인트 사용 (웹사이트 엔드포인트가 아님)
  origin {
    domain_name = "${var.s3_bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com"
    origin_id   = "S3-${var.s3_bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

# ---------------추후 주석 풀 코드 API(동적 콘텐츠) ci-cd 파이프라인 구축과 백엔드 코드 작성 완료 후 풀기---------------
  # ALB 오리진: API 요청 처리
  # origin {
  #   domain_name = aws_lb.example.dns_name  # ALB 리소스의 DNS 이름
  #   origin_id   = "ALB-API"

  #   custom_origin_config {
  #     http_port              = 80
  #     https_port             = 443
  #     origin_protocol_policy = "http-only"
  #     origin_ssl_protocols   = ["TLSv1.2"]
  #   }
  # }
# ----------------------------------------------------------------------------------------------------

  # 기본 캐시 동작 설정 (정적 컨텐츠)
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

# ---------------추후 주석 풀 코드 API(동적 콘텐츠) ci-cd 파이프라인 구축과 백엔드 코드 작성 완료 후 풀기---------------
  # API 요청에 대한 캐시 동작: "/api/*" 경로
  # ordered_cache_behavior {
  #   path_pattern           = "/api/*"
  #   target_origin_id       = "ALB-API"
  #   viewer_protocol_policy = "redirect-to-https"

  #   allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  #   cached_methods  = ["GET", "HEAD", "OPTIONS"]

  #   forwarded_values {
  #     query_string = true
  #     cookies {
  #       forward = "all"
  #     }
  #   }

  #   # 캐시를 비활성화하여 항상 오리진에서 최신 데이터를 받아오도록 구성
  #   min_ttl     = 0
  #   default_ttl = 0
  #   max_ttl     = 0
    
  #   # --------------------------------------------------------------------
  #   # 또는 AWS 관리 캐시 정책(CachingDisabled) 사용 (정책 ID는 AWS 문서를 참고)
  #   # cache_policy_id = "4130f5f2-6f63-4260-99e1-f91a8d0a7442"
  #   # --------------------------------------------------------------------
  # }
# ----------------------------------------------------------------------------------------------------


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
