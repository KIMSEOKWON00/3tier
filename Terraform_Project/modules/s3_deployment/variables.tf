variable "bucket_name" {
  description = "배포 패키지 저장용 S3 버킷의 이름 (전역에서 유일해야 함)"
  type        = string
}

variable "environment" {
  description = "환경 이름 (예: Production, Development 등)"
  type        = string
  default     = "Production"
}

variable "tags" {
  description = "버킷에 적용할 태그들"
  type        = map(string)
  default     = {
    Name        = "Deployment Bucket"
    Environment = "Production"
  }
}
