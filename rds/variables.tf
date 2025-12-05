variable "name" {
  type        = string
  description = "Name prefix for resources"
  default     = "app"
}

variable "engine" {
  type        = string
  description = "RDS engine"
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "RDS engine version (optional)"
  default     = "14"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage (GB)"
  default     = 20
}

variable "username" {
  type        = string
  description = "DB master username"
  default     = "admin"
}

variable "db_name" {
  type    = string
  default = "pgdb"
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "Private subnet ids for DB subnet group"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups to attach to DB (should allow access from EKS)"
  default     = []
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ (costly)"
  default     = false
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether DB is publicly accessible"
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
