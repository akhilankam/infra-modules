variable "cluster_name" {
  type        = string
  description = "EKS Cluster name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags"
}
