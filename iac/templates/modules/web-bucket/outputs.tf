// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "bucket_id" {

  description = "The bucket ID"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {

  description = "The bucket ARN"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_regional_domain_name" {

  description = "The bucket regional domain name"
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}
