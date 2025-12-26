data "aws_caller_identity" "current" {}

# Extract OIDC provider ID from ARN
locals {
  oidc_provider_id = replace(var.cluster_oidc_provider_arn, "/.*id//", "")
}

# -----------------------------------------------------------
# IAM Role for Service Account (IRSA)
# -----------------------------------------------------------
resource "aws_iam_role" "this" {
  name               = "${var.cluster_name}-${var.service_account_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.cluster_oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_id}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_id}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------
# IAM Policy for Service Account
# -----------------------------------------------------------
resource "aws_iam_role_policy" "this" {
  name   = "${var.cluster_name}-${var.service_account_name}-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.permissions.json
}

data "aws_iam_policy_document" "permissions" {
  dynamic "statement" {
    for_each = var.permissions

    content {
      effect    = "Allow"
      actions   = [statement.value.action]
      resources = statement.value.resources
    }
  }
}
