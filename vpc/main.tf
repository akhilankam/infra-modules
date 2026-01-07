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
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/role/internal-elb"      = "0"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  availability_zone = each.value
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.key
  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "owned"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/role/elb"               = "0"
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

  tags = {
    Name = "postgres-db-sg"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

