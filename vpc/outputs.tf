output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  value = [for s in aws_subnet.private : s.id]
}

output "database_sg_id" {
  value = aws_security_group.db.id
}