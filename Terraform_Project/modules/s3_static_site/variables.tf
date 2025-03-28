variable "bucket_name" {
  description = "전역에서 유일해야 하는 S3 버킷 이름"
  type        = string
}

variable "bucket_tags" {
  description = "S3 버킷에 적용할 태그"
  type        = map(string)
  default = {
    Name = "React Static Site"
  }
}

variable "cloudfront_oai_arn" {
  description = "CloudFront Origin Access Identity의 IAM ARN"
  type        = string
}
