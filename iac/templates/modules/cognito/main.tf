// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

resource "aws_cognito_user_pool" "user_pool" {

  name = "${var.APP}-${var.ENV}-${var.USER_POOL_NAME}"

  username_configuration {
    case_sensitive = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_subject = "${var.APP_TITLE} User Invitation"
      email_message = "<!DOCTYPE html> <html> <head> </head> <body> <br>Hello,<br> <br>Welcome to ${var.APP_TITLE}. Kindly find the credentials for the account created for you.<br> <br>User Email: {username}<br>Password: {####}<br><br>Please visit the login page, and enter the user email and password provided to login. <br><br>${var.APP_TITLE} Team</body> </html>"
      sms_message   = "Hello,\r\nWelcome to ${var.APP_TITLE}.\r\nUser Email: {username}\r\nTemporary Password: {####}\r\n${var.APP_TITLE} Team"
    }
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = false
    require_symbols                  = false
    temporary_password_validity_days = 1
  }

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "${var.APP_TITLE} User Email Verification"
    email_message        = "<!DOCTYPE html> <html> <head> </head> <body> <br>Hello,<br> <br>Welcome to ${var.APP_TITLE}. You are kindly requested to verify your email using the code: {####}. Please visit login page, click on verify button, enter your email id and the code provided and click verify.  <br><br>${var.APP_TITLE} Team</body> </html>"
  }

  mfa_configuration = "OFF"

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = false
    string_attribute_constraints {}
  }
}

resource "aws_iam_role" "group_role" {

  name = "${var.APP}-${var.ENV}-${var.REGION}-cognito-user-group-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity"
      }
    ]
  }
  EOF
}

resource "aws_cognito_user_group" "admin_group" {

  name         = "${var.APP}-${var.ENV}-admin-group"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  description  = "Admin Group"
  precedence   = 1
  role_arn     = aws_iam_role.group_role.arn
}

resource "aws_cognito_user" "admin_user" {

  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = var.ADMIN_EMAIL

  attributes = {
    email = var.ADMIN_EMAIL
  }
}

resource "aws_cognito_user_in_group" "admin_user_in_group" {

  user_pool_id = aws_cognito_user_pool.user_pool.id
  group_name   = aws_cognito_user_group.admin_group.name
  username     = aws_cognito_user.admin_user.username
}

resource "aws_cognito_user_group" "customer_1_group" {

  name         = "${var.APP}-${var.ENV}-customer-000001-group"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  description  = "Customer 1 Group"
  precedence   = 2
  role_arn     = aws_iam_role.group_role.arn
}

resource "aws_cognito_user" "customer_1_user" {

  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = var.CUSTOMER1_EMAIL

  attributes = {
    email = var.CUSTOMER1_EMAIL
  }
}

resource "aws_cognito_user_in_group" "customer1_user_in_group" {

  user_pool_id = aws_cognito_user_pool.user_pool.id
  group_name   = aws_cognito_user_group.customer_1_group.name
  username     = aws_cognito_user.customer_1_user.username
}

resource "aws_cognito_user_group" "customer_2_group" {

  name         = "${var.APP}-${var.ENV}-customer-000002-group"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  description  = "Customer 2 Group"
  precedence   = 3
  role_arn     = aws_iam_role.group_role.arn
}

resource "aws_cognito_user" "customer_2_user" {

  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = var.CUSTOMER2_EMAIL

  attributes = {
    email = var.CUSTOMER2_EMAIL
  }
}

resource "aws_cognito_user_in_group" "customer2_user_in_group" {

  user_pool_id = aws_cognito_user_pool.user_pool.id
  group_name   = aws_cognito_user_group.customer_2_group.name
  username     = aws_cognito_user.customer_2_user.username
}

resource "aws_cognito_user_pool_client" "user_pool_client" {

  name                                 = "${var.APP}-${var.ENV}-client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  generate_secret                      = false
  refresh_token_validity               = 30
  allowed_oauth_flows                  = ["code", "implicit"]
  explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  callback_urls                        = var.ALLOWED_CALL_BACKS
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true
  prevent_user_existence_errors        = "ENABLED"
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {

  domain       = "${var.APP}-${var.ENV}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_identity_pool" "identity_pool" {

  identity_pool_name               = "${var.APP}-${var.ENV}-${var.IDENTITY_POOL_NAME}"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.user_pool_client.id
    provider_name = aws_cognito_user_pool.user_pool.endpoint
  }
}

locals {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id
}

resource "aws_iam_role" "identity_role" {

  name = "${var.APP}-${var.ENV}-${var.REGION}-cognito-identity-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "cognito-identity.amazonaws.com:aud": "${local.identity_pool_id}"
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "authenticated"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "identity_role_policy" {

  name        = "${var.APP}-${var.ENV}-${var.REGION}-identity-role-policy"
  path        = "/"
  description = "identity-role-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-sync:*",
          "cognito-identity:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "execute-api:Invoke"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "identity_role_policy_attachment1" {

  role       = aws_iam_role.identity_role.name
  policy_arn = aws_iam_policy.identity_role_policy.arn
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles_attachment" {

  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    "authenticated" = aws_iam_role.identity_role.arn
  }
}

resource "aws_ssm_parameter" "user_pool_id" {

  name        = "/${var.APP}/${var.ENV}/cognito-user-pool-id"
  description = "The Cognito User Pool ID"
  type        = "SecureString"
  value       = aws_cognito_user_pool.user_pool.id
}

resource "aws_ssm_parameter" "user_pool_arn" {

  name        = "/${var.APP}/${var.ENV}/cognito-user-pool-arn"
  description = "The User Pool ARN"
  type        = "SecureString"
  value       = aws_cognito_user_pool.user_pool.arn
}

resource "aws_ssm_parameter" "app_client" {

  name        = "/${var.APP}/${var.ENV}/cognito-app-client"
  description = "The Cognito App Client"
  type        = "SecureString"
  value       = aws_cognito_user_pool_client.user_pool_client.id
}

resource "aws_ssm_parameter" "identity_pool_id" {

  name        = "/${var.APP}/${var.ENV}/cognito-identity-pool-id"
  description = "The Cognito Identity Pool ID"
  type        = "SecureString"
  value       = aws_cognito_identity_pool.identity_pool.id
}



