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

resource "aws_s3_bucket" "bucket" {

  bucket = "${var.APP}-${var.ENV}-${var.BUCKET_NAME}"

  force_destroy = true

  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled" (Skip: Intentionally skipped as it contains web static file and not data)
  #checkov:skip=CKV_AWS_19: "Ensure all data stored in the S3 bucket is securely encrypted at rest" (Skip: Intentionally left unencrypted as cloudfront needs bucket unencrypted)
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled" (Skip: Intentionally skipped as the content is separately deployed to secondary region)
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default" (Skip: Intentionally left unencrypted as cloudfront needs bucket unencrypted)
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {

  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "bucket_kms_key" {

  source = "../../modules/kms"
  providers = {
    aws = aws
  }
  NAME        = "${var.APP}-${var.ENV}-${var.BUCKET_NAME}-bucket-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-${var.BUCKET_NAME}-bucket-key"
}

resource "aws_s3_bucket_policy" "bucket_policy" {

  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}

data "aws_iam_policy_document" "bucket_policy_document" {

  statement {
    principals {
      type        = "AWS"
      identifiers = [var.CLOUDFRONT_OAI_IAM_ARN]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}

resource "aws_ssm_parameter" "bucket" {

  name        = "/${var.APP}/${var.ENV}/${var.BUCKET_NAME}"
  description = "The bucket id"
  type        = "SecureString"
  value       = aws_s3_bucket.bucket.id
}
