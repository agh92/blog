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

  client_id_list = [
    "https://github.com/agh92/blog",
    "sts.amazonaws.com"
    ]

  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# create role for the github action
resource "aws_iam_role" "this" {
  name = "github-actions-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.this.json  
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryPowerUser" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "AmazonElasticContainerRegistryPublicPowerUser" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicPowerUser"
}