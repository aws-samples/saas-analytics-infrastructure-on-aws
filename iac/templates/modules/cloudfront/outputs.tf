// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "cloudfront_id" {

  description = "The CloudFront ID"
  value       = aws_cloudfront_distribution.www_s3_distribution.id
}

output "cloudfront_arn" {

  description = "The CloudFront ARN"
  value       = aws_cloudfront_distribution.www_s3_distribution.arn
}

output "cloudfront_domain_name" {

  description = "The CloudFront Domain Name"
  value       = aws_cloudfront_distribution.www_s3_distribution.domain_name
}

output "cloudfront_oai_iam_arn" {

  description = "The CloudFront Origin Access Identity IAM ARN"
  value       = aws_cloudfront_origin_access_identity.dashboard.iam_arn
}
