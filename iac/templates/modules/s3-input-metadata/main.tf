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

data "aws_ssm_parameter" "private_subnet_1" {
  name = "/${var.APP}/${var.ENV}/private-subnet-1"
}

data "aws_ssm_parameter" "private_subnet_2" {
  name = "/${var.APP}/${var.ENV}/private-subnet-2"
}

data "aws_ssm_parameter" "private_subnet_3" {
  name = "/${var.APP}/${var.ENV}/private-subnet-3"
}

data "aws_ssm_parameter" "lambda_sg" {
  name = "/${var.APP}/${var.ENV}/lambda-sg"
}

locals {
  bucket_ids_set       = toset(var.S3_BUCKET_IDS)
  lambda_function_name = "${var.APP}-${var.ENV}-input-file-received"
  lambda_role_name     = "${var.APP}-${var.ENV}-s3-input-metadata-lambda-access"
  private_subnet_ids = [
    data.aws_ssm_parameter.private_subnet_1.value,
    data.aws_ssm_parameter.private_subnet_2.value,
    data.aws_ssm_parameter.private_subnet_3.value
  ]
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "pandas_lambda_layer" {

  name = "/${var.APP}/${var.ENV}/pandas-lambda-layer"
}

module "s3_input_events_function_kms_key" {

  source = "../../modules/kms"
  providers = {
    aws = aws
  }

  NAME        = "${local.lambda_function_name}-key"
  DESCRIPTION = "${local.lambda_function_name}-key"
}

resource "aws_lambda_function" "s3_input_events" {

  function_name = local.lambda_function_name

  s3_bucket = var.LAMBDA_CODE_S3_BUCKET_ID
  s3_key    = var.LAMBDA_CODE_S3_BUCKET_KEY

  runtime = var.RUNTIME
  handler = var.LAMBDA_HANDLER
  timeout = 300
  publish = true

  source_code_hash = var.SOURCE_CODE_HASH
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/${local.lambda_role_name}"

  vpc_config {
    subnet_ids         = local.private_subnet_ids
    security_group_ids = [data.aws_ssm_parameter.lambda_sg.value]
  }

  layers = [data.aws_ssm_parameter.pandas_lambda_layer.value]

  tracing_config {
    mode = "Active"
  }

  kms_key_arn = module.s3_input_events_function_kms_key.key_arn

  environment {
    variables = {
      ENV                          = var.ENV
      DYNAMODB_TABLE_S3_FILE_INPUT = var.DYNAMODB_TABLE_S3_FILE_INPUT
    }
  }

  //  reserved_concurrent_executions = var.CONCURRENCY
  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  #checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
  #checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
}

# Grant permissions for S3 to call the s3_input_events lambda
resource "aws_lambda_permission" "s3_input_events_allow_bucket" {
  for_each = local.bucket_ids_set

  statement_id   = "AllowExecutionFromS3Bucket_${index(var.S3_BUCKET_IDS, each.key) + 1}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.s3_input_events.arn
  principal      = "s3.amazonaws.com"
  source_arn     = "arn:aws:s3:::${each.key}"
  source_account = data.aws_caller_identity.current.account_id
}

# Register file input events on S3 buckets to call lambda function
resource "aws_s3_bucket_notification" "s3_input_bucket_notification" {
  for_each = local.bucket_ids_set

  bucket = each.key

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_input_events.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_input_events_allow_bucket]
}
