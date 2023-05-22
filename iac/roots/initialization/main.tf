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

module "waf" {

  source = "../../templates/modules/waf"
  providers = {
    aws = aws
  }

  APP            = var.APP
  ENV            = var.ENV
  USAGE          = "cloudfront"
  SCOPE          = "CLOUDFRONT"
  WHITE_LIST_IPS = var.WHITE_LIST_IPS
}

module "primary" {

  source = "../../templates/components/initialization"
  providers = {
    aws = aws.primary
  }

  APP                        = var.APP
  ENV                        = var.ENV
  REGION                     = "primary"
  APP_TITLE                  = var.APP_TITLE
  WAF_ACL_ARN                = module.waf.waf_acl_arn
  ADMIN_DISTRIBUTION_NAME    = var.ADMIN_DISTRIBUTION_NAME
  ADMIN_COMMENT              = var.ADMIN_COMMENT
  ADMIN_BUCKET_NAME          = var.ADMIN_BUCKET_NAME_PRIMARY
  ADMIN_EMAIL                = var.ADMIN_EMAIL
  CUSTOMER_DISTRIBUTION_NAME = var.CUSTOMER_DISTRIBUTION_NAME
  CUSTOMER_COMMENT           = var.CUSTOMER_COMMENT
  CUSTOMER_BUCKET_NAME       = var.CUSTOMER_BUCKET_NAME_PRIMARY
  CUSTOMER1_EMAIL            = var.CUSTOMER1_EMAIL
  CUSTOMER2_EMAIL            = var.CUSTOMER2_EMAIL
  USER_POOL_NAME             = var.USER_POOL_NAME
  IDENTITY_POOL_NAME         = var.IDENTITY_POOL_NAME
  WHITE_LIST_IPS             = var.WHITE_LIST_IPS
}

module "secondary" {

  source = "../../templates/components/initialization"
  providers = {
    aws = aws.secondary
  }

  APP                        = var.APP
  ENV                        = var.ENV
  REGION                     = "secondary"
  APP_TITLE                  = var.APP_TITLE
  WAF_ACL_ARN                = module.waf.waf_acl_arn
  ADMIN_DISTRIBUTION_NAME    = var.ADMIN_DISTRIBUTION_NAME
  ADMIN_COMMENT              = var.ADMIN_COMMENT
  ADMIN_BUCKET_NAME          = var.ADMIN_BUCKET_NAME_SECONDARY
  CUSTOMER_DISTRIBUTION_NAME = var.CUSTOMER_DISTRIBUTION_NAME
  CUSTOMER_COMMENT           = var.CUSTOMER_COMMENT
  CUSTOMER_BUCKET_NAME       = var.CUSTOMER_BUCKET_NAME_SECONDARY
  ADMIN_EMAIL                = var.ADMIN_EMAIL
  CUSTOMER1_EMAIL            = var.CUSTOMER1_EMAIL
  CUSTOMER2_EMAIL            = var.CUSTOMER2_EMAIL
  USER_POOL_NAME             = var.USER_POOL_NAME
  IDENTITY_POOL_NAME         = var.IDENTITY_POOL_NAME
  WHITE_LIST_IPS             = var.WHITE_LIST_IPS
}

