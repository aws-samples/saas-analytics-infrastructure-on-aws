// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "iam_role_arn" {

  description = "The ARN of customer S3 bucket access role"
  value       = aws_iam_role.customer_bucket.arn
}
