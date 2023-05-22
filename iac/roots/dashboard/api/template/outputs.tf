// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "api_gateway_arn" {

  description = "The ARN of the api gateway"
  value       = module.dashboard_api.api_arn
}
