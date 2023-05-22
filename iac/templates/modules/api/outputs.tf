// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "api_id" {

  description = "The API ID"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_arn" {

  description = "The API ID"
  value       = aws_api_gateway_rest_api.api.arn
}

output "api_root_resource_id" {

  description = "The API Root Resource ID"
  value       = aws_api_gateway_rest_api.api.root_resource_id
}

output "api_cognito_authorizer_id" {

  description = "The API Cognito Authorizer ID"
  value       = aws_api_gateway_authorizer.cognito_authorizer.id
}


