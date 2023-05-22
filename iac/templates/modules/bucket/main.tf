// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.primary, aws.secondary]
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  primary_bucket_name   = "${var.RESOURCE_PREFIX}-${var.BUCKET_NAME_PRIMARY_REGION}"
  secondary_bucket_name = "${var.RESOURCE_PREFIX}-${var.BUCKET_NAME_SECONDARY_REGION}"
}

data "aws_region" "primary" {

  provider = aws.primary
}

data "aws_region" "secondary" {

  provider = aws.secondary
}

# Create the S3 replication role trust policy

data "aws_iam_policy_document" "s3_assume_role_policy" {

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

# Create the primary to secondary S3 replication IAM permissions policy

resource "aws_iam_policy" "s3_crr_primary_to_secondary-policy" {

  provider = aws.primary

  name = "${var.RESOURCE_PREFIX}-s3-crr-primary-to-secondary-policy"
  path = "/service-role/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.primary_bucket_name}",
          "arn:aws:s3:::${local.primary_bucket_name}/*",
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging",
          "s3:ObjectOwnerOverrideToBucketOwner",
        ]
        Condition = {
          StringLikeIfExists = {
            "s3:x-amz-server-side-encryption" = [
              "aws:kms",
              "AES256",
            ]
          }
        }
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.secondary_bucket_name}/*",
        ]
      },
      {
        Action = [
          "kms:Decrypt",
        ]
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" = [
              "arn:aws:s3:::${local.primary_bucket_name}/*",
            ]
            "kms:ViaService" = "s3.${data.aws_region.primary.name}.amazonaws.com"
          }
        }
        Effect = "Allow"
        Resource = [
          var.PRIMARY_CMK_ARN,
        ]
      },
      {
        Action = [
          "kms:Encrypt",
        ]
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" = [
              "arn:aws:s3:::${local.secondary_bucket_name}/*",
            ]
            "kms:ViaService" = [
              "s3.${data.aws_region.secondary.name}.amazonaws.com",
            ]
          }
        }
        Effect = "Allow"
        Resource = [
          var.SECONDARY_CMK_ARN,
        ]
      },
    ]
  })
}

# Create the secondary to primary S3 replication IAM permissions policy

resource "aws_iam_policy" "s3_crr_secondary_to_primary_policy" {

  provider = aws.secondary

  name = "${var.RESOURCE_PREFIX}-s3-crr-secondary-to-primary-policy"
  path = "/service-role/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.secondary_bucket_name}",
          "arn:aws:s3:::${local.secondary_bucket_name}/*",
        ]
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging",
          "s3:ObjectOwnerOverrideToBucketOwner",
        ]
        Condition = {
          StringLikeIfExists = {
            "s3:x-amz-server-side-encryption" = [
              "aws:kms",
              "AES256",
            ]
          }
        }
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.primary_bucket_name}/*",
        ]
      },
      {
        Action = [
          "kms:Decrypt",
        ]
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" = [
              "arn:aws:s3:::${local.secondary_bucket_name}/*",
            ]
            "kms:ViaService" = "s3.${data.aws_region.secondary.name}.amazonaws.com"
          }
        }
        Effect = "Allow"
        Resource = [
          var.SECONDARY_CMK_ARN,
        ]
      },
      {
        Action = [
          "kms:Encrypt",
        ]
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" = [
              "arn:aws:s3:::${local.primary_bucket_name}/*",
            ]
            "kms:ViaService" = [
              "s3.${data.aws_region.primary.name}.amazonaws.com",
            ]
          }
        }
        Effect = "Allow"
        Resource = [
          var.PRIMARY_CMK_ARN,
        ]
      },
    ]
  })
}

# Create primary to secondary replication S3 role

resource "aws_iam_role" "primary_s3_crr_role" {

  provider = aws.primary

  name               = "${var.RESOURCE_PREFIX}-S3PrimaryCrrKmsRole"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json
}

# Create secondary to primary replication S3 role

resource "aws_iam_role" "secondary_s3_crr_role" {

  provider = aws.secondary

  name               = "${var.RESOURCE_PREFIX}-S3SecondaryCrrKmsRole"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json
}

# Assign policy to primary IAM role

resource "aws_iam_role_policy_attachment" "primary_iam_role" {

  provider = aws.primary

  policy_arn = aws_iam_policy.s3_crr_primary_to_secondary-policy.arn
  role       = aws_iam_role.primary_s3_crr_role.name
}

# Assign policy To secondary IAM role

resource "aws_iam_role_policy_attachment" "secondary_iam_role" {

  provider = aws.secondary

  policy_arn = aws_iam_policy.s3_crr_secondary_to_primary_policy.arn
  role       = aws_iam_role.secondary_s3_crr_role.name
}

# Create the primary bucket

resource "aws_s3_bucket" "primary" {

  provider = aws.primary

  bucket = local.primary_bucket_name
}

# Create the secondary bucket

resource "aws_s3_bucket" "secondary" {

  provider = aws.secondary

  bucket = local.secondary_bucket_name
}

# Block public access for primary bucket

resource "aws_s3_bucket_public_access_block" "public_access_block_primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access for secondary bucket

resource "aws_s3_bucket_public_access_block" "public_access_block_secondary" {

  provider = aws.secondary

  bucket = aws_s3_bucket.secondary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable primary bucket versioning

resource "aws_s3_bucket_versioning" "primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable secondary bucket versioning

resource "aws_s3_bucket_versioning" "secondary" {

  provider = aws.secondary

  bucket = aws_s3_bucket.secondary.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable default encryption for primary bucket

resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.bucket

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.PRIMARY_CMK_ARN
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enable default encryption for secondary bucket

resource "aws_s3_bucket_server_side_encryption_configuration" "secondary" {

  provider = aws.secondary

  bucket = aws_s3_bucket.secondary.bucket

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.SECONDARY_CMK_ARN
      sse_algorithm     = "aws:kms"
    }
  }
}

# Configure primary to secondary cross region replication

resource "aws_s3_bucket_replication_configuration" "primary_to_secondary_repl" {

  provider = aws.primary

  role   = aws_iam_role.primary_s3_crr_role.arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id = "AllToSecondary"

    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.secondary.arn
      encryption_configuration {
        replica_kms_key_id = var.SECONDARY_CMK_ARN
      }
    }

    source_selection_criteria {

      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [
    aws_s3_bucket_versioning.primary,
    aws_s3_bucket_versioning.secondary
  ]
}

# Configure secondary to primary cross region replication

resource "aws_s3_bucket_replication_configuration" "secondary_to_primary_repl" {

  provider = aws.secondary

  role   = aws_iam_role.secondary_s3_crr_role.arn
  bucket = aws_s3_bucket.secondary.id

  rule {
    id = "AllToPrimary"

    status = "Enabled"

    destination {
      bucket = aws_s3_bucket.primary.arn
      encryption_configuration {
        replica_kms_key_id = var.PRIMARY_CMK_ARN
      }
    }

    source_selection_criteria {

      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [
    aws_s3_bucket_versioning.primary,
    aws_s3_bucket_versioning.secondary
  ]
}

# Create primary log bucket

resource "aws_s3_bucket" "log_bucket_primary" {

  provider = aws.primary

  bucket = "${local.primary_bucket_name}-log"

  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
}

# Create secondary log bucket

resource "aws_s3_bucket" "log_bucket_secondary" {

  provider = aws.secondary

  bucket = "${local.secondary_bucket_name}-log"

  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
}

# Create a bucket policy for primary log bucket

resource "aws_s3_bucket_policy" "log_bucket_primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.log_bucket_primary.id
  policy = data.aws_iam_policy_document.log_bucket_primary.json
}

data "aws_iam_policy_document" "log_bucket_primary" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.log_bucket_primary.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        aws_s3_bucket.primary.arn
      ]
    }
  }
}

# Create a bucket policy for secondary log bucket

resource "aws_s3_bucket_policy" "log_bucket_secondary" {

  provider = aws.secondary

  bucket = aws_s3_bucket.log_bucket_secondary.id
  policy = data.aws_iam_policy_document.log_bucket_secondary.json
}

data "aws_iam_policy_document" "log_bucket_secondary" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.log_bucket_secondary.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        aws_s3_bucket.secondary.arn
      ]
    }
  }
}

# Block public access for primary log bucket

resource "aws_s3_bucket_public_access_block" "public_access_block_log_primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.log_bucket_primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access for secondary log bucket

resource "aws_s3_bucket_public_access_block" "public_access_block_log_secondary" {

  provider = aws.secondary

  bucket = aws_s3_bucket.log_bucket_secondary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create bucket logging for primary bucket

resource "aws_s3_bucket_logging" "log_bucket_logging_primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.primary.id

  target_bucket = aws_s3_bucket.log_bucket_primary.id
  target_prefix = "log/"
}

# Create bucket logging for secondary bucket

resource "aws_s3_bucket_logging" "log_bucket_logging_secondary" {

  provider = aws.secondary

  bucket = aws_s3_bucket.secondary.id

  target_bucket = aws_s3_bucket.log_bucket_secondary.id
  target_prefix = "log/"
}

# Enable default encryption for primary log bucket

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_primary" {

  provider = aws.primary

  bucket = aws_s3_bucket.log_bucket_primary.bucket

  # Log buckets cannot use KMS with CMK and can only use AES-256 (SSE-S3)
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable default encryption for secondary log bucket

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_secondary" {

  provider = aws.secondary

  bucket = aws_s3_bucket.log_bucket_secondary.bucket

  # Log buckets cannot use KMS with CMK and can only use AES-256 (SSE-S3)
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


