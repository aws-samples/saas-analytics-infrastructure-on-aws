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

module "admin_dashboard_apis_primary" {

  source = "./template"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  LOCATION           = "region1"
  APP                = var.APP
  ENV                = var.ENV
  API_NAME           = var.API_NAME
  STAGE              = var.STAGE
  RUNTIME            = var.RUNTIME
  LAMBDA_PROVISIONED = var.LAMBDA_PROVISIONED
}

module "admin_dashboard_apis_secondary" {

  source = "./template"
  providers = {
    aws.primary   = aws.secondary
    aws.secondary = aws.primary
  }

  LOCATION           = "region2"
  APP                = var.APP
  ENV                = var.ENV
  API_NAME           = var.API_NAME
  STAGE              = var.STAGE
  RUNTIME            = var.RUNTIME
  LAMBDA_PROVISIONED = var.LAMBDA_PROVISIONED
}
