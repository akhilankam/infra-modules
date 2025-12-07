# -----------------------------------------------------------
# Create EKS Cluster
# -----------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn

  version = var.eks_version # Controlled, not default

  vpc_config {
    subnet_ids = var.private_subnets
  }

  tags = var.tags
}


# -----------------------------------------------------------
# Enable OIDC Provider (IRSA)
# -----------------------------------------------------------
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.this.name
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0cdc9a0f6"]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# -----------------------------------------------------------
# Node Group
# -----------------------------------------------------------
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnets

  version = var.eks_version # <--- OPTIONAL but recommended

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  tags           = var.tags
}


# -----------------------------------------------------------
# ALB Ingress Controller IAM Role (IRSA)
# -----------------------------------------------------------
data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.arn, "arn:aws:iam::", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_ingress_role" {
  name               = "${var.cluster_name}-alb-ingress-role"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "alb_ingress_policy" {
  role       = aws_iam_role.alb_ingress_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

# -----------------------------------------------------------
# Cluster Autoscaler IAM Role (IRSA)
# -----------------------------------------------------------
data "aws_iam_policy_document" "cluster_autoscaler_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.arn, "arn:aws:iam::", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler_role" {
  name               = "${var.cluster_name}-cluster-autoscaler-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_policy" {
  role       = aws_iam_role.cluster_autoscaler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}
