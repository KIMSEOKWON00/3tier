output "codedeploy_app_name" {
  description = "생성된 CodeDeploy 애플리케이션 이름"
  value       = aws_codedeploy_app.this.name
}

output "codedeploy_deployment_group_name" {
  description = "생성된 CodeDeploy 배포 그룹 이름"
  value       = aws_codedeploy_deployment_group.this.deployment_group_name
}
