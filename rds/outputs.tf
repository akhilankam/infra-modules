output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_subnet_group" {
  value = aws_db_subnet_group.this.name
}

output "secretsmanager_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}
