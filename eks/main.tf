provider "aws" {
  region = var.region
}

# -----------------------------------------------------------
# Create EKS Cluster
# -----------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn

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
  thumbprint_list = [data.aws_eks_cluster.eks.identity[0].oidc[0].thumbprint]
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

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  tags           = var.tags
}
