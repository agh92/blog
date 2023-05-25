terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  # TODO figure this out in github actions
  # shared_config_files       = 
  # shared_credentials_files  = 
  # region                    = 
}

# create private container registry
resource "aws_ecr_repository" "this" {
  name                 = "github"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# create OIDC for github
resource "aws_iam_openid_connect_provider" "this" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# create role for the github action

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
      values = [ "repo:agh92/${aws_ecr_repository.this.name}:*" ] 
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

resource "aws_iam_role" "this" {
  name = "github-actions-role"

  assume_role_policy = data.aws_iam_policy_document.this.json
}