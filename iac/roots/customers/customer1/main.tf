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

locals {
  SFTP_USERS = [
    for config in var.SFTP_USERS : {
      name                = config.name
      home_directory_type = config.home_directory_type
      public_key          = file("${path.module}/sftp-user-public-keys/${config.name}.pub")
    }
  ]
}

module "primary_kms_key" {

  source = "../../../templates/modules/kms"
  providers = {
    aws = aws.primary
  }

  NAME        = "${var.APP}-${var.ENV}-customer-${var.CUSTOMER}-primary-KMS-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-customer-${var.CUSTOMER}-primary-KMS-key"
}

module "secondary_kms_key" {

  source = "../../../templates/modules/kms"
  providers = {
    aws = aws.secondary
  }

  NAME        = "${var.APP}-${var.ENV}-customer-${var.CUSTOMER}-secondary-KMS-key"
  DESCRIPTION = "${var.APP}-${var.ENV}-customer-${var.CUSTOMER}-secondary-KMS-key"
}

module "customer" {

  source = "../../../templates/components/customer"
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }

  APP                   = var.APP
  ENV                   = var.ENV
  CUSTOMER              = var.CUSTOMER
  PRIMARY_KMS_KEY_ARN   = module.primary_kms_key.key_arn
  SECONDARY_KMS_KEY_ARN = module.secondary_kms_key.key_arn
  SFTP_USERS            = local.SFTP_USERS
}
