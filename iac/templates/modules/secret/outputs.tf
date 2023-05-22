// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "secret_id" {

  description = "The ID of the Secret"
  value       = aws_secretsmanager_secret.secret.id
}

output "secret_arn" {

  description = "The ARN of the Secret"
  value       = aws_secretsmanager_secret.secret.arn
}

output "secret_version_id" {

  description = "The ID of the Secret Version"
  value       = aws_secretsmanager_secret_version.secret-version.id
}

output "secret_version_arn" {

  description = "The ARN of the Secret Version"
  value       = aws_secretsmanager_secret_version.secret-version.arn
}
