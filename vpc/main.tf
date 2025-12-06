resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  availability_zone       = each.value
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.key
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  availability_zone = each.value
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.key
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

}

resource "aws_security_group" "db" {
  name        = "pqsql-db-sg"
  description = "Allow DB access within VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
