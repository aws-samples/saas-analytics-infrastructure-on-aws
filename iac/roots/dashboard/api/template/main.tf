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

module "primary_kms_key" {

  source = "../../../../templates/modules/kms"
  providers = {
    aws = aws.primary
  }

  NAME        = "${var.APP}-${var.ENV}-${var.LOCATION}-admin-dashboard-primary-KMS-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-${var.LOCATION}-admin-dashboard-primary-KMS-key"
}

module "secondary_kms_key" {

  source = "../../../../templates/modules/kms"
  providers = {
    aws = aws.secondary
  }

  NAME        = "${var.APP}-${var.ENV}-${var.LOCATION}-admin-dashboard-secondary-KMS-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-${var.LOCATION}-admin-dashboard-secondary-KMS-key"
}

module "lambda_bucket" {

  source = "../../../../templates/modules/bucket"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  RESOURCE_PREFIX              = "${var.APP}-${var.ENV}-${var.LOCATION}-admin-dashboard"
  BUCKET_NAME_PRIMARY_REGION   = "primary"
  BUCKET_NAME_SECONDARY_REGION = "secondary"
  PRIMARY_CMK_ARN              = module.primary_kms_key.key_arn
  SECONDARY_CMK_ARN            = module.secondary_kms_key.key_arn
}

data "archive_file" "lambda_archive" {

  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/saas.zip"
}

resource "aws_s3_object" "lambda_object" {

  provider = aws.primary
  bucket   = module.lambda_bucket.primary_bucket_id

  key    = "saas.zip"
  source = data.archive_file.lambda_archive.output_path

  etag = filemd5(data.archive_file.lambda_archive.output_path)

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
  private_subnet_ids = [data.aws_ssm_parameter.private_subnet_1.value,
    data.aws_ssm_parameter.private_subnet_2.value,
  data.aws_ssm_parameter.private_subnet_3.value]
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

module "dashboard_api" {

  source = "../../../../templates/modules/api"
  providers = {
    aws = aws.primary
  }

  ENV      = var.ENV
  APP      = var.APP
  API_NAME = var.API_NAME
}

module "get_analytics_api_method" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-analytics"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_analytics"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-analytics"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "execute_analytics_api_method" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "execute-analytics"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.execute_analytics"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "execute-analytics"
  METHOD_NAME               = "POST"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_customers_api_method" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-customers"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_customers"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-customers"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_input_files_api_method" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-input-files"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_customer_input_files"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-input-files"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_output_files_api_method" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-output-files"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_customer_output_files"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-output-files"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_customer_input_files_api_method" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-cust-input-files"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_input_files_for_a_customer"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-cust-input-files"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_customer_output_files_api_method" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-cust-output-files"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_output_files_for_a_customer"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-cust-output-files"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_file_content" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-file-content"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_file_content"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-file-content"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "put_file_content" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "put-file-content"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.put_file_content"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "put-file-content"
  METHOD_NAME               = "POST"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_file_events" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-file-events"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_file_events"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-file-events"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "get_analytics_events" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "get-analytics-events"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.get_analytics_events"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "get-analytics-events"
  METHOD_NAME               = "GET"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

module "update_password" {

  source = "../../../../templates/modules/api-method"
  providers = {
    aws = aws.primary
  }

  ENV                       = var.ENV
  APP                       = var.APP
  FUNCTION_NAME             = "update-password"
  S3_BUCKET                 = module.lambda_bucket.primary_bucket_id
  S3_KEY                    = aws_s3_object.lambda_object.key
  SOURCE_CODE_HASH          = data.archive_file.lambda_archive.output_base64sha256
  LAMBDA_HANDLER            = "analytics.update_password"
  LAMBDA_OPTIONS_HANDLER    = "analytics.options"
  LAMBDA_IAM_ROLE           = data.aws_iam_role.lambda_exec_role.arn
  API_IAM_ROLE              = data.aws_iam_role.api_exec_role.arn
  SUBNET_IDS                = local.private_subnet_ids
  SECURITY_GROUP_IDS        = [data.aws_ssm_parameter.lambda_sg.value]
  API_NAME                  = var.API_NAME
  API_ID                    = module.dashboard_api.api_id
  API_ROOT_RESOURCE_ID      = module.dashboard_api.api_root_resource_id
  API_COGNITO_AUTHORIZER_ID = module.dashboard_api.api_cognito_authorizer_id
  RESOURCE_NAME             = "update-password"
  METHOD_NAME               = "POST"
  CONCURRENCY               = var.LAMBDA_PROVISIONED
  RUNTIME                   = var.RUNTIME
}

locals {
  redeployment = sha1(jsonencode([
    module.get_analytics_api_method.gateway_resource_id,

    module.get_analytics_api_method.lambda_function_id,
    module.get_analytics_api_method.function_gateway_integration_id,
    module.get_analytics_api_method.lambda_options_id,
    module.get_analytics_api_method.options_gateway_integration_id,

    module.execute_analytics_api_method.lambda_function_id,
    module.execute_analytics_api_method.function_gateway_integration_id,
    module.execute_analytics_api_method.lambda_options_id,
    module.execute_analytics_api_method.options_gateway_integration_id,

    module.get_customers_api_method.lambda_function_id,
    module.get_customers_api_method.function_gateway_integration_id,
    module.get_customers_api_method.lambda_options_id,
    module.get_customers_api_method.options_gateway_integration_id,

    module.get_input_files_api_method.lambda_function_id,
    module.get_input_files_api_method.function_gateway_integration_id,
    module.get_input_files_api_method.lambda_options_id,
    module.get_input_files_api_method.options_gateway_integration_id,

    module.get_output_files_api_method.lambda_function_id,
    module.get_output_files_api_method.function_gateway_integration_id,
    module.get_output_files_api_method.lambda_options_id,
    module.get_output_files_api_method.options_gateway_integration_id,

    module.get_customer_input_files_api_method.lambda_function_id,
    module.get_customer_input_files_api_method.function_gateway_integration_id,
    module.get_customer_input_files_api_method.lambda_options_id,
    module.get_customer_input_files_api_method.options_gateway_integration_id,

    module.get_customer_output_files_api_method.lambda_function_id,
    module.get_customer_output_files_api_method.function_gateway_integration_id,
    module.get_customer_output_files_api_method.lambda_options_id,
    module.get_customer_output_files_api_method.options_gateway_integration_id,

    module.get_file_content.lambda_function_id,
    module.get_file_content.function_gateway_integration_id,
    module.get_file_content.lambda_options_id,
    module.get_file_content.options_gateway_integration_id,

    module.put_file_content.lambda_function_id,
    module.put_file_content.function_gateway_integration_id,
    module.put_file_content.lambda_options_id,
    module.put_file_content.options_gateway_integration_id,

    module.get_file_events.lambda_function_id,
    module.get_file_events.function_gateway_integration_id,
    module.get_file_events.lambda_options_id,
    module.get_file_events.options_gateway_integration_id,

    module.get_analytics_events.lambda_function_id,
    module.get_analytics_events.function_gateway_integration_id,
    module.get_analytics_events.lambda_options_id,
    module.get_analytics_events.options_gateway_integration_id,

    module.update_password.lambda_function_id,
    module.update_password.function_gateway_integration_id,
    module.update_password.lambda_options_id,
    module.update_password.options_gateway_integration_id
  ]))
}

module "dashboard_api_deployment" {

  source = "../../../../templates/modules/api-deployment"
  providers = {
    aws = aws.primary
  }

  ENV                 = var.ENV
  APP                 = var.APP
  API_NAME            = var.API_NAME
  API_ID              = module.dashboard_api.api_id
  CLOUDWATCH_IAM_ROLE = data.aws_iam_role.cloudwatch_role.arn
  DEPLOYMENT_TRIGGER  = local.redeployment
  STAGE               = var.STAGE
  METHODS = [module.get_analytics_api_method.lambda_function_alias_arn, module.get_analytics_api_method.lambda_options_alias_arn,
    module.execute_analytics_api_method.lambda_function_alias_arn, module.execute_analytics_api_method.lambda_options_alias_arn,
    module.get_customers_api_method.lambda_function_alias_arn, module.get_customers_api_method.lambda_options_alias_arn,
    module.get_input_files_api_method.lambda_function_alias_arn, module.get_input_files_api_method.lambda_options_alias_arn,
    module.get_output_files_api_method.lambda_function_alias_arn, module.get_output_files_api_method.lambda_options_alias_arn,
    module.get_customer_input_files_api_method.lambda_function_alias_arn, module.get_customer_input_files_api_method.lambda_options_alias_arn,
    module.get_customer_output_files_api_method.lambda_function_alias_arn, module.get_customer_output_files_api_method.lambda_options_alias_arn,
    module.get_file_content.lambda_function_alias_arn, module.get_file_content.lambda_options_alias_arn,
    module.put_file_content.lambda_function_alias_arn, module.put_file_content.lambda_options_alias_arn,
    module.get_file_events.lambda_function_alias_arn, module.get_file_events.lambda_options_alias_arn,
    module.get_analytics_events.lambda_function_alias_arn, module.get_analytics_events.lambda_options_alias_arn,
  module.update_password.lambda_function_alias_arn, module.update_password.lambda_options_alias_arn]
}

