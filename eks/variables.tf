variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "public_subnets" {
  type        = list(string)
  description = "public subnets for node groups"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "eks_cluster_role_arn" {
  type        = string
  description = "IAM Role ARN for EKS Cluster"
}

variable "eks_node_role_arn" {
  type        = string
  description = "IAM Role ARN for Worker Nodes"
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "eks_version" {
  description = "EKS Kubernetes version (must be explicitly set)"
  type        = string
}
