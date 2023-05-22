// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

locals {
  read_bucket_resources  = concat(tolist(var.READ_BUCKET_ARNS), [for arn in var.READ_BUCKET_ARNS : "${arn}/*"])
  write_bucket_resources = concat(tolist(var.WRITE_BUCKET_ARNS), [for arn in var.WRITE_BUCKET_ARNS : "${arn}/*"])
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "trust_policy" {

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "StringLike"
      variable = "sts:RoleSessionName"
      values = [
        "$${aws:username}"
      ]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
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
        "arn:aws:transfer:*:${data.aws_caller_identity.current.account_id}:user/*"
      ]
    }
  }
}

data "aws_iam_policy_document" "access_policy" {

  statement {
    sid    = "readBucket"
    effect = "Allow"
    actions = [
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketVersioning",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectAttributes",
      "s3:GetObjectLegalHold",
      "s3:GetBucketLocation",
      "s3:GetObjectRetention",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionAttributes",
      "s3:GetObjectVersionTagging",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketVersions",
    ]

    resources = local.read_bucket_resources
  }

  statement {
    sid    = "decryptBucketObjects"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]

    resources = [
      var.PRIMARY_CMK_ARN,
      var.SECONDARY_CMK_ARN
    ]
  }

  statement {
    sid    = "writeToBucket"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
    ]

    resources = local.write_bucket_resources
  }

  statement {
    sid    = "encryptBucketObjects"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      var.PRIMARY_CMK_ARN,
      var.SECONDARY_CMK_ARN
    ]
  }
}

resource "aws_iam_role" "customer_bucket" {

  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  name               = "${var.RESOURCE_PREFIX}-bucket-access"
  inline_policy {
    name   = "bucketAccess"
    policy = data.aws_iam_policy_document.access_policy.json
  }
}
