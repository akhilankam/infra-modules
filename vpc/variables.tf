variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = map(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnets" {
  type        = map(string)
  description = "CIDR blocks for private subnets"
}

variable "region" {
  type        = string
  description = "AWS region"
}