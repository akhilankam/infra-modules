locals {
  service_account_name = "aws-load-balancer-controller"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# -------------------------------------------

# IAM policy for ALB controller

# -------------------------------------------

data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${local.service_account_name}"]
    }

  }
}

resource "aws_iam_role" "alb_role" {
  name               = "${var.cluster_name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}

# Attach AWS Managed Policy for ALB controller

data "http" "alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.alb_policy.body
}

resource "aws_iam_role_policy_attachment" "alb_role_attach" {
  role       = aws_iam_role.alb_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

# -------------------------------------------

# Deploy AWS Load Balancer Controller

# -------------------------------------------

resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = local.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_role.arn
    }
  }
}

resource "helm_release" "alb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.namespace
  depends_on = [
    kubernetes_service_account.alb_sa,
    aws_iam_role_policy_attachment.alb_role_attach
  ]

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "region"
      value = data.aws_region.current.name
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]
}

data "aws_region" "current" {}
