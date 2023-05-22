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

module "primary_vpc" {

  source = "../../templates/modules/vpc"
  providers = {
    aws = aws.primary
  }

  APP                  = var.APP
  ENV                  = var.ENV
  AWS_PRIMARY_REGION   = var.AWS_PRIMARY_REGION
  AWS_SECONDARY_REGION = var.AWS_SECONDARY_REGION
  CIDR                 = var.PRIMARY_CIDR
  PRIVATE_SUBNETS      = var.PRIMARY_PRIVATE_SUBNETS
  PUBLIC_SUBNETS       = var.PRIMARY_PUBLIC_SUBNETS
}

module "secondary_vpc" {

  source = "../../templates/modules/vpc"
  providers = {
    aws = aws.secondary
  }

  APP                  = var.APP
  ENV                  = var.ENV
  AWS_PRIMARY_REGION   = var.AWS_SECONDARY_REGION
  AWS_SECONDARY_REGION = var.AWS_PRIMARY_REGION
  CIDR                 = var.SECONDARY_CIDR
  PRIVATE_SUBNETS      = var.SECONDARY_PRIVATE_SUBNETS
  PUBLIC_SUBNETS       = var.SECONDARY_PUBLIC_SUBNETS
}

module "primary_file_transfer" {

  source = "../../templates/modules/file-transfer"
  providers = {
    aws = aws.primary
  }

  APP              = var.APP
  ENV              = var.ENV
  CREATE_ROLE      = true
  VPC_ID           = module.primary_vpc.vpc_id
  SUBNET_IDS       = module.primary_vpc.public_subnets
  ALLOW_SFTP_CIDRS = (var.AWS_PRIMARY_REGION == "us-east-1") ? ["pl-4e2ece27"] : ["pl-5aa44133"]
  //  ALLOW_SFTP_CIDRS = var.ALLOW_SFTP_CIDRS
}

module "secondary_file_transfer" {

  source = "../../templates/modules/file-transfer"
  providers = {
    aws = aws.secondary
  }

  APP              = var.APP
  ENV              = var.ENV
  CREATE_ROLE      = false
  VPC_ID           = module.secondary_vpc.vpc_id
  SUBNET_IDS       = module.secondary_vpc.public_subnets
  ALLOW_SFTP_CIDRS = (var.AWS_SECONDARY_REGION == "us-east-1") ? ["pl-4e2ece27"] : ["pl-5aa44133"]
  //  ALLOW_SFTP_CIDRS = var.ALLOW_SFTP_CIDRS
}
