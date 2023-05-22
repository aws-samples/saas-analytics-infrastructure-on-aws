// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

provider "aws" {

  alias  = "primary"
  region = var.AWS_PRIMARY_REGION
}

provider "aws" {

  alias  = "secondary"
  region = var.AWS_SECONDARY_REGION
}

module "primary_kms_key" {

  source = "../../../templates/modules/kms"
  providers = {
    aws = aws.primary
  }

  NAME        = "${var.APP}-${var.ENV}-analytics-${var.ANALYTICS}-primary-KMS-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-analytics-${var.ANALYTICS}-primary-KMS-key"
}

module "secondary_kms_key" {

  source = "../../../templates/modules/kms"
  providers = {
    aws = aws.secondary
  }

  NAME        = "${var.APP}-${var.ENV}-analytics-${var.ANALYTICS}-secondary-KMS-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-analytics-${var.ANALYTICS}-secondary-KMS-key"
}

module "primary" {

  source = "../../../templates/components/analytics"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  AWS_PRIMARY_REGION           = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION         = var.AWS_SECONDARY_REGION
  REGION_ID                    = "1"
  APP                          = var.APP
  ENV                          = var.ENV
  APP_TITLE                    = var.APP_TITLE
  ANALYTICS                    = var.ANALYTICS
  PRIMARY_KMS_KEY_ARN          = module.primary_kms_key.key_arn
  SECONDARY_KMS_KEY_ARN        = module.secondary_kms_key.key_arn
  PATH                         = path.module
  STAGE                        = var.STAGE
  RUNTIME                      = var.RUNTIME
  IS_ACTIVE_DR_REGION          = true
  CUSTOMER_IDS                 = var.CUSTOMER_IDS
  DYNAMODB_TABLE_S3_FILE_INPUT = aws_dynamodb_table.file_events.name
  LAMBDA_PROVISIONED           = var.LAMBDA_PROVISIONED
}

module "secondary" {

  source = "../../../templates/components/analytics"
  providers = {
    aws.primary   = aws.secondary
    aws.secondary = aws.primary
  }

  AWS_PRIMARY_REGION           = var.AWS_SECONDARY_REGION
  AWS_SECONDARY_REGION         = var.AWS_PRIMARY_REGION
  REGION_ID                    = "2"
  APP                          = var.APP
  ENV                          = var.ENV
  APP_TITLE                    = var.APP_TITLE
  ANALYTICS                    = var.ANALYTICS
  PRIMARY_KMS_KEY_ARN          = module.secondary_kms_key.key_arn
  SECONDARY_KMS_KEY_ARN        = module.primary_kms_key.key_arn
  PATH                         = path.module
  STAGE                        = var.STAGE
  RUNTIME                      = var.RUNTIME
  IS_ACTIVE_DR_REGION          = false
  CUSTOMER_IDS                 = var.CUSTOMER_IDS
  DYNAMODB_TABLE_S3_FILE_INPUT = aws_dynamodb_table.file_events.name
  LAMBDA_PROVISIONED           = var.LAMBDA_PROVISIONED
}

# Global table to track analytics execution stats
resource "aws_dynamodb_table" "analytics_execution" {

  name             = "${var.APP}-${var.ENV}-analytics-execution"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  hash_key  = "ExecutionDate" # "2022-10-31"
  range_key = "ExecutionId"
  attribute {
    name = "ExecutionDate"
    type = "S"
  }
  attribute {
    name = "ExecutionId"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = module.primary_kms_key.key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  replica {
    region_name            = var.AWS_SECONDARY_REGION
    kms_key_arn            = module.secondary_kms_key.key_arn
    point_in_time_recovery = true
    propagate_tags         = true
  }

  tags = {
    Name = "${var.APP}-${var.ENV}-analytics-execution"
  }

  #checkov:skip=CKV2_AWS_16: "Ensure that Auto Scaling is enabled on your DynamoDB tables"
}

# Global table to track analytics for file input and output events
resource "aws_dynamodb_table" "file_events" {

  name             = "${var.APP}-${var.ENV}-file-events"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  hash_key  = "CustomerID"
  range_key = "CreatedIndex"
  attribute {
    name = "CustomerID"
    type = "S"
  }
  attribute {
    # ISO-8601 formatted string + file name e.g. "2022-11-03T19:20:52.612Z|input-2022-11-03-000001-000555.csv"
    name = "CreatedIndex"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = module.primary_kms_key.key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  replica {
    region_name            = var.AWS_SECONDARY_REGION
    kms_key_arn            = module.secondary_kms_key.key_arn
    point_in_time_recovery = true
    propagate_tags         = true
  }

  tags = {
    Name = "${var.APP}-${var.ENV}-file-events"
  }

  #checkov:skip=CKV2_AWS_16: "Ensure that Auto Scaling is enabled on your DynamoDB tables"
}
