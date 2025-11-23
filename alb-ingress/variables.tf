variable "cluster_name" {
description = "EKS cluster name"
type        = string
}

variable "cluster_oidc_provider_arn" {
description = "OIDC provider ARN for IRSA"
type        = string
}

variable "namespace" {
description = "Namespace to deploy ALB controller"
type        = string
default     = "kube-system"
}
