output "cloudfront_domain_name" {
  description = "CloudFront 배포의 도메인 이름 (CDN 엔드포인트)"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "oai_iam_arn" {
  description = "CloudFront Origin Access Identity ID"
  value       = aws_cloudfront_origin_access_identity.oai.iam_arn
}

output "oai_id" {
  description = "CloudFront Origin Access Identity ID"
  value       = aws_cloudfront_origin_access_identity.oai.id
}
