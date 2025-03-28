output "db_instance_endpoint" {
  description = "생성된 RDS 인스턴스의 엔드포인트"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_id" {
  description = "RDS 인스턴스의 식별자"
  value       = aws_db_instance.this.id
}
