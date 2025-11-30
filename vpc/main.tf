provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value
}

resource "aws_security_group" "db" {
  name        = "pqsql-db-sg"
  description = "Allow DB access within VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = aws_vpc.main.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
