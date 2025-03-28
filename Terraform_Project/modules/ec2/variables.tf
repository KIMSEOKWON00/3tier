variable "instance_type" {
  description = "EC2 인스턴스 타입 (예: t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH 키 페어 이름"
  type        = string
  default     = "test_app_key"
}

variable "iam_instance_profile_name" {
  description = "EC2 인스턴스에 연결할 IAM 인스턴스 프로파일 이름"
  type        = string
}

variable "security_group_ids" {
  description = "EC2 인스턴스에 적용할 보안 그룹 ID 목록"
  type        = list(string)
}

variable "user_data" {
  description = "EC2 인스턴스 부팅 시 실행할 user_data 스크립트 (base64 인코딩 필요 없음)"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    # 시스템 업데이트 및 기본 패키지 설치
    yum update -y

    #-------------------------------
    # CodeDeploy 에이전트 설치
    #-------------------------------
    yum install -y ruby wget
    cd /home/ec2-user
    wget https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/install
    chmod +x ./install
    ./install auto
    systemctl start codedeploy-agent
    systemctl enable codedeploy-agent

    #-------------------------------
    # Docker 설치 및 설정
    #-------------------------------
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user

    #-------------------------------
    # Docker Compose 설치 (옵션)
    #-------------------------------
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  EOF
}
