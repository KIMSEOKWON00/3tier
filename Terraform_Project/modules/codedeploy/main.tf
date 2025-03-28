########################################
# CodeDeploy 애플리케이션 생성
########################################
resource "aws_codedeploy_app" "this" {
  name             = var.app_name
  compute_platform = "Server"  # EC2/온프레미스 배포를 위한 설정
}

########################################
# CodeDeploy 배포 그룹 생성 (오토스케일링 그룹 대상)
########################################
resource "aws_codedeploy_deployment_group" "this" {
  app_name              = aws_codedeploy_app.this.name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = var.service_role_arn
  deployment_config_name = var.deployment_config_name
  autoscaling_groups    = var.autoscaling_groups

  auto_rollback_configuration {
    enabled = var.auto_rollback_enabled
    events  = var.auto_rollback_events
  }
}
