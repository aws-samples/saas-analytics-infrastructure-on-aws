// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "key_id" {

  description = "The ID of the Key"
  value       = aws_kms_key.key.id
}

output "key_arn" {

  description = "The ARN of the Key"
  value       = aws_kms_key.key.arn
}
