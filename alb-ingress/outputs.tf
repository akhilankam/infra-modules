output "alb_role_arn" {
description = "IAM Role ARN used by ALB Ingress Controller"
value       = aws_iam_role.alb_role.arn
}
