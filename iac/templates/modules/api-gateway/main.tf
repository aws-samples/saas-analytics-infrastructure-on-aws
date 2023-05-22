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

  function_name = "${var.APP}-${var.ENV}-${var.FUNCTION_NAME}"

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

  environment {
    variables = {
      ENV = var.ENV
    }
  }

  #checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
  #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  #checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "key" {

  description         = "${var.APP}-${var.ENV}-${var.FUNCTION_NAME}-log-key"
  enable_key_rotation = true

  tags = {
    Name = "${var.APP}-${var.ENV}-${var.FUNCTION_NAME}-log-key"
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

  name          = "alias/${var.APP}-${var.ENV}-${var.FUNCTION_NAME}-log-key"
  target_key_id = aws_kms_key.key.key_id
}

resource "aws_cloudwatch_log_group" "function_log_group" {

  name       = "/aws/lambda/${var.APP}/${var.ENV}/${aws_lambda_function.function.function_name}"
  kms_key_id = aws_kms_key.key.arn

  retention_in_days = 30
}

resource "aws_lambda_function" "options" {

  function_name = "${var.APP}-${var.ENV}-${var.FUNCTION_NAME}-opts"

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

resource "aws_cloudwatch_log_group" "options_log_group" {

  name       = "/aws/lambda/${var.APP}/${var.ENV}/${aws_lambda_function.options.function_name}"
  kms_key_id = aws_kms_key.key.arn

  retention_in_days = 30
}

resource "aws_api_gateway_rest_api" "api" {

  name        = "${var.APP}-${var.ENV}-${var.API_NAME}"
  description = var.API_NAME

  lifecycle {
    create_before_destroy = true
  }

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "aws_secretsmanager_secret" "user_pool_arn_secret" {

  name = "${var.APP}-${var.ENV}-cognito-user-pool-arn"
}

data "aws_secretsmanager_secret_version" "user_pool_arn_secret_version" {

  secret_id = data.aws_secretsmanager_secret.user_pool_arn_secret.id
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {

  name            = "${var.APP}-${var.ENV}-${var.API_NAME}-cognito-authorizer"
  identity_source = "method.request.header.authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [data.aws_secretsmanager_secret_version.user_pool_arn_secret_version.secret_string]
  rest_api_id     = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "resource" {

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.RESOURCE_NAME
}

resource "aws_api_gateway_method" "method" {

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id

  api_key_required = false
  http_method      = var.METHOD_NAME
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method" "options" {

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "method_integration" {

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
  credentials             = var.API_IAM_ROLE
}

resource "aws_api_gateway_integration" "options_integration" {

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.options.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.options.invoke_arn
  credentials             = var.API_IAM_ROLE
}

resource "aws_api_gateway_deployment" "deployment" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.method_integration.id,
      aws_api_gateway_method.options.id,
      aws_api_gateway_integration.options_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_resource.resource,
    aws_api_gateway_method.method,
    aws_api_gateway_integration.method_integration,
    aws_api_gateway_method.options,
    aws_api_gateway_integration.options_integration
  ]
}

data "aws_elb_service_account" "main" {}

resource "aws_api_gateway_account" "demo" {

  cloudwatch_role_arn = var.CLOUDWATCH_IAM_ROLE
}

resource "aws_cloudwatch_log_group" "log_group" {

  name              = "api-gateway-${var.APP}-${var.ENV}-${var.FUNCTION_NAME}"
  kms_key_id        = aws_kms_key.key.arn
  retention_in_days = 90
}

resource "aws_api_gateway_stage" "stage" {

  deployment_id         = aws_api_gateway_deployment.deployment.id
  rest_api_id           = aws_api_gateway_rest_api.api.id
  stage_name            = var.STAGE
  cache_cluster_enabled = false
  xray_tracing_enabled  = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format          = "$context.requestId"
  }

  #checkov:skip=CKV_AWS_120: "Ensure API Gateway caching is enabled" (when caching is enabled it delivers stale response)
  #checkov:skip=CKV2_AWS_29: "Ensure public API gateway are protected by WAF"
}

resource "aws_api_gateway_method_settings" "all" {

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
    caching_enabled = true
  }
}

resource "aws_lambda_permission" "method_permission" {

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*"
}

resource "aws_lambda_permission" "options_permission" {

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.options.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*"
}

resource "aws_api_gateway_api_key" "key" {

  name = var.API_NAME
}

resource "aws_api_gateway_usage_plan" "usage_plan" {

  name = var.API_NAME

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {

  key_id        = aws_api_gateway_api_key.key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

