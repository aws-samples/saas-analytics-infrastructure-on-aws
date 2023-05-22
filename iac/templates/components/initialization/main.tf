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

module "secret_manager_kms_key" {

  source = "../../modules/kms"
  providers = {
    aws = aws
  }

  NAME        = "${var.APP}-${var.ENV}-secret-manager-secret-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-secret-manager-secret-key"
}

resource "aws_lambda_layer_version" "pandas" {

  filename            = "${path.module}/python.zip"
  layer_name          = "pandas"
  source_code_hash    = filebase64sha256("${path.module}/python.zip")
  compatible_runtimes = ["python3.8"]
}

resource "aws_ssm_parameter" "pandas_lambda_layer" {

  name        = "/${var.APP}/${var.ENV}/pandas-lambda-layer"
  description = "The Pandas lambda layer"
  type        = "SecureString"
  value       = aws_lambda_layer_version.pandas.arn
  overwrite   = true
}

module "cloudfront_admin_dashboard" {

  source = "../../modules/cloudfront"
  providers = {
    aws = aws
  }

  APP               = var.APP
  ENV               = var.ENV
  DISTRIBUTION_NAME = var.ADMIN_DISTRIBUTION_NAME
  COMMENT           = var.ADMIN_COMMENT
  BUCKET_NAME       = var.ADMIN_BUCKET_NAME
  WEB_ACL_ARN       = var.WAF_ACL_ARN
}

module "cloudfront_customer_dashboard" {

  source = "../../modules/cloudfront"
  providers = {
    aws = aws
  }

  APP               = var.APP
  ENV               = var.ENV
  DISTRIBUTION_NAME = var.CUSTOMER_DISTRIBUTION_NAME
  COMMENT           = var.CUSTOMER_COMMENT
  BUCKET_NAME       = var.CUSTOMER_BUCKET_NAME
  WEB_ACL_ARN       = var.WAF_ACL_ARN
}

module "web_bucket_admin" {

  source = "../../modules/web-bucket"
  providers = {
    aws = aws
  }

  APP                    = var.APP
  ENV                    = var.ENV
  BUCKET_NAME            = var.ADMIN_BUCKET_NAME
  CLOUDFRONT_OAI_IAM_ARN = module.cloudfront_admin_dashboard.cloudfront_oai_iam_arn
}

module "web_bucket_customer" {

  source = "../../modules/web-bucket"
  providers = {
    aws = aws
  }

  APP                    = var.APP
  ENV                    = var.ENV
  BUCKET_NAME            = var.CUSTOMER_BUCKET_NAME
  CLOUDFRONT_OAI_IAM_ARN = module.cloudfront_customer_dashboard.cloudfront_oai_iam_arn
}

module "cognito" {


  source = "../../modules/cognito"
  providers = {
    aws = aws
  }

  APP                = var.APP
  ENV                = var.ENV
  REGION             = var.REGION
  APP_TITLE          = var.APP_TITLE
  ADMIN_EMAIL        = var.ADMIN_EMAIL
  CUSTOMER1_EMAIL    = var.CUSTOMER1_EMAIL
  CUSTOMER2_EMAIL    = var.CUSTOMER2_EMAIL
  ALLOWED_CALL_BACKS = ["https://${module.cloudfront_admin_dashboard.cloudfront_domain_name}"]
  USER_POOL_NAME     = var.USER_POOL_NAME
  IDENTITY_POOL_NAME = var.IDENTITY_POOL_NAME

  depends_on = [
    module.cloudfront_admin_dashboard
  ]
}

module "waf_api" {

  source = "../../modules/waf"
  providers = {
    aws = aws
  }

  APP            = var.APP
  ENV            = var.ENV
  USAGE          = "api"
  SCOPE          = "REGIONAL"
  WHITE_LIST_IPS = var.WHITE_LIST_IPS
}
