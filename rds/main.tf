# random password for master user
resource "random_password" "rds_master" {
  length           = 24
  special          = true
  override_special = "!@#$%^&*()_-+="
}

# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-db-subnet-group" })
}

# RDS instance
resource "aws_db_instance" "this" {
  identifier              = "${var.name}-db"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  username                = var.username
  password                = random_password.rds_master.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  multi_az                = var.multi_az
  publicly_accessible     = var.publicly_accessible
  skip_final_snapshot     = true
  deletion_protection     = false
  tags                    = merge(var.tags, { Name = "${var.name}-db" })
  # minimal for dev: avoid automatic backups retention to reduce cost if desired (careful)
  backup_retention_period = 1
  apply_immediately       = true
}

# Write credentials to Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.name}-db-credentials"
  description = "Credentials for RDS instance ${aws_db_instance.this.identifier}"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.rds_master.result
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = aws_db_instance.this.name
  })
}
