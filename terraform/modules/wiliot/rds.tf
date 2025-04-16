
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.name_prefix}-rds-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.name_prefix}-postgres"
  engine                 = "postgres"
  engine_version         = "17.2"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_encrypted      = true
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [] # Fill in via variable or reference SG
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "${var.name_prefix}-rds"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_username" {
  value = aws_db_instance.this.username
}