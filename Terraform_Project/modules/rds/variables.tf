variable "db_subnet_ids" {
  description = "DB 서브넷 그룹에 사용할 서브넷 ID 목록"
  type        = list(string)
}

variable "allocated_storage" {
  description = "할당할 스토리지 용량 (GB)"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "스토리지 타입"
  type        = string
  default     = "gp2"
}

variable "engine" {
  description = "DB 엔진 (예: mysql)"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "DB 엔진 버전"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS 인스턴스 클래스"
  type        = string
  default     = "db.t3.micro"
}

variable "username" {
  description = "RDS 접속 사용자명"
  type        = string
}

variable "password" {
  description = "RDS 접속 비밀번호"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "멀티 AZ 옵션 활성화 여부"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "DB 인스턴스의 퍼블릭 접근 여부"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "삭제 시 최종 스냅샷 생략 여부"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "RDS 인스턴스에 적용할 VPC 보안 그룹 ID 목록"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "DB 서브넷 그룹 이름 (빈 문자열이면 자동 생성)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "RDS 관련 리소스에 적용할 태그"
  type        = map(string)
  default     = {
    Name = "Multi-AZ RDS Instance"
  }
}
