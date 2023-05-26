data "aws_iam_policy_document" "this" {
  statement {
    actions = [ "sts:AssumeRoleWithWebIdentity" ]
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [ "repo:agh92/blog:*" ] 
    }

    condition {
      test = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [ var.github_aud ]
    }

    condition {
      test = "StringEquals"
      variable = "token.actions.githubusercontent.com:iss"
      values = [ var.oidc_url ]
    }
  }
}

data "tls_certificate" "github" {
  url = "${var.oidc_url}/.well-known/openid-configuration"
}