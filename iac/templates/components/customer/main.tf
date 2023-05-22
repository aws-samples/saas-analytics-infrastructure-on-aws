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

module "input_bucket" {

  source = "../../modules/bucket"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  RESOURCE_PREFIX              = "${var.APP}-${var.ENV}-customer-input-${var.CUSTOMER}"
  BUCKET_NAME_PRIMARY_REGION   = "primary"
  BUCKET_NAME_SECONDARY_REGION = "secondary"
  PRIMARY_CMK_ARN              = var.PRIMARY_KMS_KEY_ARN
  SECONDARY_CMK_ARN            = var.SECONDARY_KMS_KEY_ARN
}

module "output_bucket" {

  source = "../../modules/bucket"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  RESOURCE_PREFIX              = "${var.APP}-${var.ENV}-customer-output-${var.CUSTOMER}"
  BUCKET_NAME_PRIMARY_REGION   = "primary"
  BUCKET_NAME_SECONDARY_REGION = "secondary"
  PRIMARY_CMK_ARN              = var.PRIMARY_KMS_KEY_ARN
  SECONDARY_CMK_ARN            = var.SECONDARY_KMS_KEY_ARN
}

module "bucket_access" {

  source = "../../modules/bucket-access"

  RESOURCE_PREFIX   = "${var.APP}-${var.ENV}-customer-${var.CUSTOMER}"
  PRIMARY_CMK_ARN   = var.PRIMARY_KMS_KEY_ARN
  SECONDARY_CMK_ARN = var.SECONDARY_KMS_KEY_ARN
  READ_BUCKET_ARNS = [
    module.output_bucket.primary_bucket_arn,
    module.output_bucket.secondary_bucket_arn,
    module.input_bucket.primary_bucket_arn,
    module.input_bucket.secondary_bucket_arn
  ]
  WRITE_BUCKET_ARNS = [
    module.input_bucket.primary_bucket_arn,
    module.input_bucket.secondary_bucket_arn
  ]
}

module "sftp_user" {

  for_each = { for user in var.SFTP_USERS : user.name => user }
  source   = "../../modules/file-transfer-user"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  APP                      = var.APP
  ENV                      = var.ENV
  ROLE_ARN                 = module.bucket_access.iam_role_arn
  USER_NAME                = each.key
  PUBLIC_KEY               = each.value.public_key
  PRIMARY_HOME_DIRECTORY   = each.value.home_directory_type == "input" ? module.input_bucket.primary_bucket_id : module.output_bucket.primary_bucket_id
  SECONDARY_HOME_DIRECTORY = each.value.home_directory_type == "input" ? module.input_bucket.secondary_bucket_id : module.output_bucket.secondary_bucket_id
}
