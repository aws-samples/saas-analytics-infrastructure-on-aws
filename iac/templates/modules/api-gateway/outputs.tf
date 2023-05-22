// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "lambda_function_arn" {

  description = "The ARN of the lambda function"
  value       = aws_lambda_function.function.arn
}

output "lambda_function_name" {

  description = "The name of the lambda function"
  value       = aws_lambda_function.function.function_name
}

output "api_gateway_arn" {

  description = "The ARN of the api gateway"
  value       = aws_api_gateway_rest_api.api.arn
}


