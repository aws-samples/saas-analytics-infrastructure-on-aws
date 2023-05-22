// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "gateway_resource_id" {

  description = "The ID of the api gateway resource"
  value       = aws_api_gateway_resource.resource.id
}

output "lambda_function_alias_arn" {

  description = "The ARN of the lambda function alias"
  value       = aws_lambda_alias.function.arn
}

output "lambda_function_arn" {

  description = "The ARN of the lambda function"
  value       = aws_lambda_function.function.arn
}

output "lambda_function_id" {

  description = "The ID of the lambda function"
  value       = aws_lambda_function.function.id
}

output "function_gateway_integration_id" {

  description = "The Gateway Integration ID of the lambda function"
  value       = aws_api_gateway_integration.method_integration.id
}

output "lambda_options_alias_arn" {

  description = "The ARN of the lambda function alias"
  value       = aws_lambda_alias.options.arn
}

output "lambda_options_arn" {

  description = "The ARN of the lambda function"
  value       = aws_lambda_function.options.arn
}

output "lambda_options_id" {

  description = "The ID of the lambda function"
  value       = aws_lambda_function.options.id
}

output "options_gateway_integration_id" {

  description = "The Gateway Integration ID of the lambda options"
  value       = aws_api_gateway_integration.options_integration.id
}

output "lambda_function_name" {

  description = "The name of the lambda function"
  value       = aws_lambda_function.function.function_name
}






