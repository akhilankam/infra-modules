variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "cluster_oidc_provider_arn" {
  type        = string
  description = "OIDC Provider ARN from EKS cluster"
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name"
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Kubernetes namespace for the service account"
}

variable "permissions" {
  type = list(object({
    action    = string
    resources = list(string)
  }))
  description = "List of IAM permissions (action and resources) to grant"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags"
}
