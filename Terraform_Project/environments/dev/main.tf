module "network" {
  source = "../../modules/network"

  vpc_cidr = "10.1.0.0/16"
  
  public_subnets = [
    { cidr = "10.1.1.0/24", az = "ap-northeast-2a" },
    { cidr = "10.1.2.0/24", az = "ap-northeast-2c" }
  ]
  
  private_app_subnets = [
    { cidr = "10.1.3.0/24", az = "ap-northeast-2a" },
    { cidr = "10.1.5.0/24", az = "ap-northeast-2c" }
  ]
  
  private_db_subnets = [
    { cidr = "10.1.4.0/24", az = "ap-northeast-2a" },
    { cidr = "10.1.6.0/24", az = "ap-northeast-2c" }
  ]
}

# 비용이 많이 나와서 테스트 구동 시 사용하지 않음
# module "rds" {
#   source = "../../modules/rds"

#   db_subnet_ids         = module.network.private_db_subnet_ids  # 네트워크 모듈의 출력값 사용
#   username              = "testuser"        # 실제 사용자명으로 변경
#   password              = "password"        # 실제 비밀번호로 변경
#   vpc_security_group_ids = [module.security_groups.rds_sg_id]  # RDS 전용 보안 그룹 ID

#   # 옵션으로 다른 값들도 변경할 수 있음
#   allocated_storage  = 20
#   storage_type       = "gp2"
#   engine             = "mysql"
#   engine_version     = "8.0"
#   instance_class     = "db.t3.micro"
#   multi_az           = true
#   publicly_accessible = false
#   skip_final_snapshot = true

#   tags = {
#     Name = "Multi-AZ RDS Instance"
#   }
# }


module "s3_static_site" {
  source              = "../../modules/s3_static_site"

  bucket_name         = "my-react-static-site-unique"  # 전역에서 유일한 이름 사용
  cloudfront_oai_arn  = module.cdn.oai_iam_arn
}

module "cdn" {
  source         = "../../modules/cdn"
  s3_bucket_name = module.s3_static_site.s3_bucket_name
  # default_root_object는 기본값 "index.html"을 사용하거나 필요시 변경 가능
}

module "s3_deployment" {
  source      = "../../modules/s3_deployment"
  bucket_name = "my-deployment-bucket-unique-12345678"  # 반드시 전역에서 유일해야 함
  environment = "dev"
  tags = {
    Name        = "Deployment Bucket"
    Environment = "dev"
  }
}

module "ecr" {
  source           = "../../modules/ecr"
  repository_name  = "my-react-app-repo"
  tags = {
    Name        = "React App Repo"
    Environment = "Production"
  }
}

module "iam" {
  source = "../../modules/iam"

  # 필요시 변수 값을 오버라이드할 수 있습니다.
  codedeploy_role_name       = "MyCodeDeployRole"
  ec2_role_name              = "MyEC2Role"
  ec2_instance_profile_name  = "MyEC2InstanceProfile"
}


module "security_groups" {
  source = "../../modules/security_groups"
  vpc_id = module.network.vpc_id  # VPC 생성 리소스의 ID를 전달
}

module "codedeploy" {
  source                = "../../modules/codedeploy"
  app_name              = "my-codedeploy-app"
  deployment_group_name = "my-deployment-group"
  service_role_arn      = module.iam.codedeploy_role_arn
  autoscaling_groups    = [module.asg.asg_name] 
}

module "ec2" {
  source = "../../modules/ec2"

  instance_type              = "t3.micro"
  key_name                   = "test_app_key"
  iam_instance_profile_name  = module.iam.ec2_instance_profile_name
  security_group_ids         = [module.security_groups.app_sg_id]
  # user_data는 기본값을 사용하거나 별도로 수정 가능
}

module "asg" {
  source = "../../modules/asg"

  environment           = "dev"
  asg_name              = "app-asg-dev"
  vpc_zone_identifier   = module.network.private_app_subnet_ids
  launch_template_id    = module.ec2.launch_template_id
  launch_template_version = "$Latest"
  desired_capacity      = 2
  min_size              = 1
  max_size              = 3
  target_group_arns     = [module.alb.target_group_arn] // 아직 alb 모듈 생성전 생성 후 추가
  health_check_type         = "EC2"
  health_check_grace_period = 300
  instance_tag_name     = "app-instance"

  depends_on = [
    module.network,  // network 모듈이 완료된 후 실행
    module.alb,      // alb 모듈이 완료된 후 실행
    module.ec2       // ec2 모듈이 완료된 후 실행
  ]

}

module "alb" {
  source              = "../../modules/alb"
  environment         = "dev"
  alb_name            = "app-alb"
  subnet_ids          = module.network.public_subnet_ids  # 네트워크 모듈의 출력값 사용 가능
  security_group_ids  = [module.security_groups.alb_sg_id]                   # ALB 전용 보안 그룹
  vpc_id              = module.network.vpc_id                                 # 네트워크 모듈의 VPC ID 사용
  # 나머지 변수들은 기본값 사용 (필요시 tfvars 또는 직접 값 지정)
}


module "openvpn" {
  source = "../../modules/openvpn"

  ami                    = "ami-0da165fc7156630d7"  # 실제 ap-northeast-2 리전의 OpenVPN AMI ID
  instance_type          = "t3.small"
  subnet_id              = module.network.public_subnet_ids[0]   # 사용 중인 퍼블릭 서브넷 ID
  associate_public_ip_address = true
  vpc_security_group_ids = [module.security_groups.openvpn_sg_id]
  
  # 필요시 추가 태그 지정
  instance_tags = {
    Environment = "dev"
  }
}


