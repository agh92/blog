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
      values = [ "sts.amazonaws.com" ]
    }

    condition {
      test = "StringEquals"
      variable = "token.actions.githubusercontent.com:iss"
      values = [ "https://token.actions.githubusercontent.com" ]
    }
  }
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}