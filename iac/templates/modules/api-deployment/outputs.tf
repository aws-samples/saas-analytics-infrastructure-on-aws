// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "gateway_deployment_id" {

  description = "The API Gateway Deployment ID"
  value       = aws_api_gateway_deployment.deployment.id
}






