output "alb_arn" {
  description = "생성된 ALB의 ARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "생성된 ALB의 DNS 이름"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "생성된 ALB 대상 그룹의 ARN"
  value       = aws_lb_target_group.this.arn
}

output "listener_arn" {
  description = "생성된 ALB 리스너의 ARN"
  value       = aws_lb_listener.this.arn
}
