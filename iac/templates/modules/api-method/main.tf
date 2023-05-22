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

data "aws_ssm_parameter" "pandas_lambda_layer" {

  name = "/${var.APP}/${var.ENV}/pandas-lambda-layer"
}

module "function_kms_key" {

  source = "../../modules/kms"
  providers = {
    aws = aws
  }

  NAME        = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-key"
}

resource "aws_lambda_function" "function" {

  function_name = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}"

  s3_bucket = var.S3_BUCKET
  s3_key    = var.S3_KEY

  runtime = var.RUNTIME
  handler = var.LAMBDA_HANDLER
  timeout = 300
  publish = true

  source_code_hash = var.SOURCE_CODE_HASH

  role = var.LAMBDA_IAM_ROLE

  vpc_config {
    subnet_ids         = var.SUBNET_IDS
    security_group_ids = var.SECURITY_GROUP_IDS
  }

  layers = [data.aws_ssm_parameter.pandas_lambda_layer.value]

  tracing_config {
    mode = "Active"
  }

  kms_key_arn = module.function_kms_key.key_arn

  memory_size = 2048
  ephemeral_storage {
    size = 2048
  }

  environment {
    variables = {
      APP = var.APP
      ENV = var.ENV
    }
  }

  #checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  #checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
}

resource "aws_lambda_alias" "function" {

  name             = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}"
  description      = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}"
  function_name    = aws_lambda_function.function.arn
  function_version = aws_lambda_function.function.version
}

resource "aws_lambda_provisioned_concurrency_config" "function" {

  function_name                     = aws_lambda_function.function.function_name
  provisioned_concurrent_executions = var.CONCURRENCY
  qualifier                         = aws_lambda_function.function.version
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "key" {

  description         = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-log-key"
  enable_key_rotation = true

  tags = {
    Name = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-log-key"
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnLike": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_kms_alias" "key_alias" {

  name          = "alias/${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-log-key"
  target_key_id = aws_kms_key.key.key_id
}

resource "aws_cloudwatch_log_group" "function_log_group" {

  name       = "/aws/lambda/${var.APP}/${var.ENV}/${var.API_NAME}/${aws_lambda_function.function.function_name}"
  kms_key_id = aws_kms_key.key.arn

  retention_in_days = 30

  depends_on = [
    aws_kms_key.key
  ]
}

resource "aws_lambda_function" "options" {

  function_name = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-opts"

  s3_bucket = var.S3_BUCKET
  s3_key    = var.S3_KEY

  runtime = var.RUNTIME
  handler = var.LAMBDA_OPTIONS_HANDLER
  timeout = 300
  publish = true

  source_code_hash = var.SOURCE_CODE_HASH

  role = var.LAMBDA_IAM_ROLE

  vpc_config {
    subnet_ids         = var.SUBNET_IDS
    security_group_ids = var.SECURITY_GROUP_IDS
  }

  layers = [data.aws_ssm_parameter.pandas_lambda_layer.value]

  tracing_config {
    mode = "Active"
  }

  #checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  #checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
}

resource "aws_lambda_alias" "options" {

  name             = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-opts"
  description      = "${var.APP}-${var.ENV}-${var.API_NAME}-${var.FUNCTION_NAME}-opts"
  function_name    = aws_lambda_function.options.arn
  function_version = aws_lambda_function.options.version
}

resource "aws_lambda_provisioned_concurrency_config" "options" {

  function_name                     = aws_lambda_function.options.function_name
  provisioned_concurrent_executions = var.CONCURRENCY
  qualifier                         = aws_lambda_function.options.version
}

resource "aws_cloudwatch_log_group" "options_log_group" {

  name       = "/aws/lambda/${var.APP}/${var.ENV}/${var.API_NAME}/${aws_lambda_function.options.function_name}"
  kms_key_id = aws_kms_key.key.arn

  retention_in_days = 30

  depends_on = [
    aws_kms_key.key
  ]
}

resource "aws_api_gateway_resource" "resource" {

  rest_api_id = var.API_ID
  parent_id   = var.API_ROOT_RESOURCE_ID
  path_part   = var.RESOURCE_NAME
}

resource "aws_api_gateway_method" "method" {

  rest_api_id = var.API_ID
  resource_id = aws_api_gateway_resource.resource.id

  api_key_required = false
  http_method      = var.METHOD_NAME
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = var.API_COGNITO_AUTHORIZER_ID
}

resource "aws_api_gateway_method" "options" {

  rest_api_id   = var.API_ID
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "method_integration" {

  rest_api_id             = var.API_ID
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.function.invoke_arn
  credentials             = var.API_IAM_ROLE
}

resource "aws_api_gateway_integration" "options_integration" {

  rest_api_id             = var.API_ID
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.options.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.options.invoke_arn
  credentials             = var.API_IAM_ROLE
}



