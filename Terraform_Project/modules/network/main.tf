########################################
# VPC 및 인터넷 게이트웨이 생성
########################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main-IGW"
  }
}

########################################
# 퍼블릭 서브넷 생성 및 NAT 게이트웨이 구성
########################################

# 퍼블릭 서브넷 생성 (동적 count 사용)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index].cidr
  availability_zone       = var.public_subnets[count.index].az
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-${count.index + 1}"
  }
}

# NAT Elastic IP (퍼블릭 서브넷별)
resource "aws_eip" "nat" {
  count  = length(var.public_subnets)
  domain = "vpc"
  depends_on = [aws_vpc.main]

  tags = {
    Name = "NAT-EIP-${count.index + 1}"
  }
}

# NAT 게이트웨이 생성 (각 퍼블릭 서브넷에 하나씩)
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_eip.nat]

  tags = {
    Name = "NAT-GW-${count.index + 1}"
  }
}

# 퍼블릭 라우트 테이블 생성 (인터넷 게이트웨이 경로)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RT"
  }
}

# 퍼블릭 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

########################################
# 프라이빗 서브넷 생성
########################################

# 어플리케이션 인스턴스용 프라이빗 서브넷 (NAT 연결)
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnets[count.index].cidr
  availability_zone = var.private_app_subnets[count.index].az
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-App-${count.index + 1}"
  }
}

# 데이터베이스 인스턴스용 프라이빗 서브넷 (내부 전용, NAT 미연결)
resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnets[count.index].cidr
  availability_zone = var.private_db_subnets[count.index].az
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-DB-${count.index + 1}"
  }
}

########################################
# 프라이빗 라우트 테이블 생성 및 서브넷 연결
########################################

# 어플리케이션용 프라이빗 라우트 테이블 (NAT 경로 포함)
resource "aws_route_table" "private_app_rt" {
  count  = length(var.private_app_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "Private-App-RT-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_app_assoc" {
  count          = length(var.private_app_subnets)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app_rt[count.index].id
}

# 데이터베이스용 프라이빗 라우트 테이블 (내부 통신용, NAT 없음)
resource "aws_route_table" "private_db_rt" {
  count  = length(var.private_db_subnets)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private-DB-RT-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_db_assoc" {
  count          = length(var.private_db_subnets)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db_rt[count.index].id
}
