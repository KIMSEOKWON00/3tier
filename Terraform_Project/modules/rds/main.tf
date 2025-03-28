# DB 서브넷 그룹을 생성합니다.
resource "random_id" "db_suffix" {
  byte_length = 4
}

resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name != "" ? var.db_subnet_group_name : "rds-subnet-group-${random_id.db_suffix.hex}"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "RDS Subnet Group"
  }
}

# RDS 인스턴스를 생성합니다.
resource "aws_db_instance" "this" {
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot

  vpc_security_group_ids = var.vpc_security_group_ids

  tags = var.tags
}
