// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

locals {
  s3_origin_id = "s3-www.${var.BUCKET_NAME}"
}

data "aws_region" "current" {}

resource "aws_cloudfront_origin_access_identity" "dashboard" {

  comment = var.COMMENT
}

resource "aws_cloudfront_distribution" "www_s3_distribution" {

  origin {
    domain_name = "${var.APP}-${var.ENV}-${var.BUCKET_NAME}.s3.${data.aws_region.current.name}.amazonaws.com"
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.dashboard.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.WEB_ACL_ARN

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  #checkov:skip=CKV_AWS_86: "Ensure Cloudfront distribution has Access Logging enabled"
  #checkov:skip=CKV_AWS_174: "Verify CloudFront Distribution Viewer Certificate is using TLS v1.2"
  #checkov:skip=CKV2_AWS_32: "Ensure CloudFront distribution has a strict security headers policy attached"
}

resource "aws_ssm_parameter" "domain_name" {

  name        = "/${var.APP}/${var.ENV}/${var.DISTRIBUTION_NAME}/cloudfront-domain-name"
  description = "The Cloudfront Domain Name"
  type        = "SecureString"
  value       = aws_cloudfront_distribution.www_s3_distribution.domain_name
  overwrite   = true
}
