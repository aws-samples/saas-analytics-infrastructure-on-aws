// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "user_pool_id" {

  description = "The User Pool Id"
  value       = aws_cognito_user_pool.user_pool.id
}

output "user_pool_arn" {

  description = "The User Pool ARN"
  value       = aws_cognito_user_pool.user_pool.id
}

output "admin_user_id" {

  description = "The admin user Id"
  value       = aws_cognito_user.admin_user.id
}

output "app_client_id" {

  description = "The app client id"
  value       = aws_cognito_user_pool_client.user_pool_client.id
}

output "identity_pool_id" {

  description = "The Identity Pool Id"
  value       = aws_cognito_identity_pool.identity_pool.id
}
