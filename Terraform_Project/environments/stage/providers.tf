terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92.0"
    }
  }

  # (옵션) 백엔드 설정: 원격 상태 저장소를 사용하는 경우 설정
#   backend "s3" {
#     bucket = "my-terraform-state-bucket"
#     key    = "prod/terraform.tfstate"
#     region = "ap-northeast-2"
#   }
}

provider "aws" {
  region = "ap-northeast-2"
}