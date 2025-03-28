# ALB 생성 (인터넷-facing)
resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  tags = {
    Environment = var.environment
    Name        = var.alb_name
  }
}

# ALB 대상 그룹 생성 (예: HTTP 포트 80)
resource "aws_lb_target_group" "this" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    path     = var.health_check_path
    protocol = var.health_check_protocol
    matcher  = var.health_check_matcher
  }

  tags = {
    Environment = var.environment
    Name        = var.target_group_name
  }
}

# ALB 리스너 생성 (ALB로 들어오는 요청을 대상 그룹으로 포워딩)
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
