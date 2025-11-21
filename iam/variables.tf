variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC Provider ARN for IRSA"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags"
}
