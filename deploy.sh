#!/bin/bash
set -e

echo "Starting deployment..."

# 현재 실행 중인 컨테이너가 있다면 중지
if docker ps -q --filter "name=my-react-app" | grep -q .; then
  echo "Stopping current container..."
  docker stop my-react-app && docker rm my-react-app
fi

# ECR 리포지토리 URI를 가져옵니다.
REPO_URI=$(aws ecr describe-repositories --repository-names my-react-app-repo --region ap-northeast-2 --query 'repositories[0].repositoryUri' --output text)

echo "Pulling latest image from ECR..."
# ECR에 대해 Docker 로그인 (리포지토리 URI에서 계정 ID 부분 추출)
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${REPO_URI%%/*}

# 최신 이미지 pull
docker pull $REPO_URI:latest

# 새 컨테이너 실행 (포트 80을 EC2의 80 포트에 바인딩)
echo "Starting new container..."
docker run -d --name my-react-app -p 80:80 $REPO_URI:latest

# 헬스 체크: HTTP 상태 코드 200이 반환되는지 확인 (최대 12회, 5초 간격)
# MAX_RETRIES=12
# SLEEP_INTERVAL=5
# SUCCESS=false

# echo "Waiting for the application to start..."
# for (( i=1; i<=MAX_RETRIES; i++ )); do
#   HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" http://localhost)
#   echo "Attempt $i: HTTP status code - $HTTP_CODE"
#   if [ "$HTTP_CODE" -eq 200 ]; then
#     SUCCESS=true
#     break
#   fi
#   sleep $SLEEP_INTERVAL
# done

# if [ "$SUCCESS" = true ]; then
#   echo "Deployment successful."
# else
#   echo "Deployment failed. Expected HTTP 200, but got $HTTP_CODE after $((MAX_RETRIES * SLEEP_INTERVAL)) seconds."
#   exit 1
# fi

# exit 0
