output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = data.aws_eks_cluster.eks.endpoint
}

output "cluster_certificate_authority" {
  value = data.aws_eks_cluster.eks.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "alb_ingress_role_arn" {
  value = aws_iam_role.alb_ingress_role.arn
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler_role.arn
}