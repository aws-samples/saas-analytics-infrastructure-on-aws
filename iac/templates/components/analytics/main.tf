// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.primary, aws.secondary]
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

resource "random_string" "suffix" {

  length           = 6
  upper            = false
  lower            = true
  special          = false
  override_special = ""
}

module "lambda_bucket" {

  source = "../../modules/bucket"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  RESOURCE_PREFIX              = "${var.APP}-${var.ENV}-analytics-${var.ANALYTICS}-${var.REGION_ID}"
  BUCKET_NAME_PRIMARY_REGION   = "primary"
  BUCKET_NAME_SECONDARY_REGION = "secondary"
  PRIMARY_CMK_ARN              = var.PRIMARY_KMS_KEY_ARN
  SECONDARY_CMK_ARN            = var.SECONDARY_KMS_KEY_ARN
}

data "archive_file" "lambda_analytics" {

  type = "zip"

  source_dir  = "${var.PATH}/src"
  output_path = "${var.PATH}/saas.zip"
}

resource "aws_s3_object" "lambda_analytics" {

  provider = aws.primary
  bucket   = module.lambda_bucket.primary_bucket_id

  key    = "saas.zip"
  source = data.archive_file.lambda_analytics.output_path

  etag = filemd5(data.archive_file.lambda_analytics.output_path)

  #checkov:skip=CKV_AWS_186: "Ensure S3 bucket Object is encrypted by KMS using a customer managed Key (CMK)"
}

data "aws_ssm_parameter" "private_subnet_1" {

  provider = aws.primary
  name     = "/${var.APP}/${var.ENV}/private-subnet-1"
}

data "aws_ssm_parameter" "private_subnet_2" {

  provider = aws.primary
  name     = "/${var.APP}/${var.ENV}/private-subnet-2"
}

data "aws_ssm_parameter" "private_subnet_3" {

  provider = aws.primary
  name     = "/${var.APP}/${var.ENV}/private-subnet-3"
}

locals {
  private_subnet_ids = [
    data.aws_ssm_parameter.private_subnet_1.value,
    data.aws_ssm_parameter.private_subnet_2.value,
    data.aws_ssm_parameter.private_subnet_3.value
  ]

  input_file_lambda_suffix = "input-file-received"
  region_description       = var.IS_ACTIVE_DR_REGION ? "primary" : "secondary"
}

data "aws_ssm_parameter" "lambda_sg" {

  provider = aws.primary
  name     = "/${var.APP}/${var.ENV}/lambda-sg"
}

data "aws_iam_role" "lambda_exec_role" {

  provider = aws.primary
  name     = "${var.APP}-${var.ENV}-lambda-role"
}

data "aws_iam_role" "api_exec_role" {

  provider = aws.primary
  name     = "${var.APP}-${var.ENV}-api-role"
}

data "aws_iam_role" "cloudwatch_role" {

  provider = aws.primary
  name     = "${var.APP}-${var.ENV}-cloudwatch-role"
}

module "analytics_api" {

  source = "../../modules/api"
  providers = {
    aws = aws.primary
  }

  ENV      = var.ENV
  APP      = var.APP
  API_NAME = var.ANALYTICS
}

module "analytics_api_method" {

  source = "../../modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = var.ANALYTICS
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_analytics.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_analytics.output_base64sha256
  LAMBDA_HANDLER            = "analytics.execute"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.ANALYTICS
  API_ID                    = module.analytics_api.api_id
  API_ROOT_RESOURCE_ID      = module.analytics_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.analytics_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "execute"
  METHOD_NAME               = "POST"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

locals {
  redeployment = sha1(jsonencode([
    module.analytics_api_method.gateway_resource_id,

    module.analytics_api_method.lambda_function_id,
    module.analytics_api_method.function_gateway_integration_id,
    module.analytics_api_method.lambda_options_id,
    module.analytics_api_method.options_gateway_integration_id,

  ]))
}

module "analytics_api_deployment" {

  source = "../../modules/api-deployment"
  providers = {
    aws = aws.primary
  }

  ENV                 = var.ENV
  APP                 = var.APP
  API_NAME            = var.ANALYTICS
  API_ID              = module.analytics_api.api_id
  CLOUDWATCH_IAM_ROLE = data.aws_iam_role.cloudwatch_role.arn
  DEPLOYMENT_TRIGGER  = local.redeployment
  STAGE               = var.STAGE
  METHODS             = [module.analytics_api_method.lambda_function_alias_arn, module.analytics_api_method.lambda_options_alias_arn]
}

module "scheduler" {

  source = "../../modules/event-scheduler"
  providers = {
    aws = aws.primary
  }

  APP                      = var.APP
  ENV                      = var.ENV
  APP_TITLE                = var.APP_TITLE
  IS_SCHEDULE_RULE_ENABLED = var.IS_ACTIVE_DR_REGION
  TARGET_LAMBDA_ARN        = module.analytics_api_method.lambda_function_arn
  TARGET_LAMBDA_NAME       = module.analytics_api_method.lambda_function_name
}

module "s3-input-metadata" {

  source = "../../modules/s3-input-metadata"
  providers = {
    aws = aws.primary
  }

  APP                          = var.APP
  ENV                          = var.ENV
  LAMBDA_CODE_S3_BUCKET_ID     = module.lambda_bucket.primary_bucket_id
  LAMBDA_CODE_S3_BUCKET_KEY    = aws_s3_object.lambda_analytics.key
  LAMBDA_HANDLER               = "s3-input-events.execute"
  SOURCE_CODE_HASH             = data.archive_file.lambda_analytics.output_base64sha256
  S3_BUCKET_IDS                = [for customerId in var.CUSTOMER_IDS : "${var.APP}-${var.ENV}-customer-input-${customerId}-${local.region_description}"]
  DYNAMODB_TABLE_S3_FILE_INPUT = var.DYNAMODB_TABLE_S3_FILE_INPUT
}
