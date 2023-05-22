// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "lambda_function_arn" {

  description = "The ARN of the lambda function"
  value       = module.analytics_api_method.lambda_function_arn
}

output "api_gateway_arn" {

  description = "The ARN of the api gateway"
  value       = module.analytics_api.api_arn
}
