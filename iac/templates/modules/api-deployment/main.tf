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

resource "aws_api_gateway_deployment" "deployment" {

  rest_api_id = var.API_ID

  triggers = {
    redeployment = var.DEPLOYMENT_TRIGGER
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_api_gateway_account" "demo" {

  cloudwatch_role_arn = var.CLOUDWATCH_IAM_ROLE
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "key" {

  description         = "${var.APP}-${var.ENV}-${var.API_NAME}-log-key"
  enable_key_rotation = true

  tags = {
    Name = "${var.APP}-${var.ENV}-${var.API_NAME}-log-key"
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

resource "aws_cloudwatch_log_group" "log_group" {

  name              = "api-gateway-${var.APP}-${var.ENV}-${var.API_NAME}"
  kms_key_id        = aws_kms_key.key.arn
  retention_in_days = 90
}

data "aws_ssm_parameter" "pandas_lambda_layer" {

  name = "/${var.APP}/${var.ENV}/pandas-lambda-layer"
}

data "aws_ssm_parameter" "api_waf_acl_arn" {

  name = "/${var.APP}/${var.ENV}/api/waf-acl-arn"
}

resource "aws_api_gateway_stage" "stage" {

  deployment_id         = aws_api_gateway_deployment.deployment.id
  rest_api_id           = var.API_ID
  stage_name            = var.STAGE
  cache_cluster_enabled = false
  xray_tracing_enabled  = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_group.arn
    format          = "$context.requestId"
  }

  #checkov:skip=CKV_AWS_120: "Ensure API Gateway caching is enabled" (when caching is enabled it delivers stale response)
  #checkov:skip=CKV2_AWS_29: "Ensure public API gateway are protected by WAF" (API gateways are protected by WAF below, false negative)
}

resource "aws_wafv2_web_acl_association" "waf_association" {

  resource_arn = aws_api_gateway_stage.stage.arn
  web_acl_arn  = data.aws_ssm_parameter.api_waf_acl_arn.value
}

resource "aws_api_gateway_method_settings" "all" {

  rest_api_id = var.API_ID
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
    caching_enabled = true
  }
}

resource "aws_lambda_permission" "lambda_permission" {

  count = length(var.METHODS)

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.METHODS[count.index]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.deployment.execution_arn}*/*"
}

resource "aws_ssm_parameter" "api_endpoint" {

  name        = "/${var.APP}/${var.ENV}/${var.API_NAME}/api-endpoint"
  description = "The API Endpoint"
  type        = "SecureString"
  value       = aws_api_gateway_stage.stage.invoke_url
}
