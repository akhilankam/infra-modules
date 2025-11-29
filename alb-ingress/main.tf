locals {
service_account_name = "aws-load-balancer-controller"
}

# -------------------------------------------

# IAM policy for ALB controller

# -------------------------------------------

data "aws_iam_policy_document" "alb_assume_role" {
statement {
actions = ["sts:AssumeRoleWithWebIdentity"]

```
principals {
  type        = "Federated"
  identifiers = [var.cluster_oidc_provider_arn]
}

condition {
  test     = "StringEquals"
  variable = "${replace(var.cluster_oidc_provider_arn, "arn:aws:iam::", "")}:sub"
  values   = ["system:serviceaccount:${var.namespace}:${local.service_account_name}"]
}
```

}
}

resource "aws_iam_role" "alb_role" {
name               = "${var.cluster_name}-alb-controller-role"
assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}

# Attach AWS Managed Policy for ALB controller

resource "aws_iam_role_policy_attachment" "alb_role_attach" {
role       = aws_iam_role.alb_role.name
policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

# -------------------------------------------

# Deploy AWS Load Balancer Controller

# -------------------------------------------

resource "helm_release" "alb" {
name       = "aws-load-balancer-controller"
repository = "[https://aws.github.io/eks-charts](https://aws.github.io/eks-charts)"
chart      = "aws-load-balancer-controller"
namespace  = var.namespace

set {
name  = "clusterName"
value = var.cluster_name
}

set {
name  = "serviceAccount.create"
value = "false"
}

set {
name  = "serviceAccount.name"
value = local.service_account_name
}

set {
name  = "region"
value = data.aws_region.current.name
}
}

data "aws_region" "current" {}
