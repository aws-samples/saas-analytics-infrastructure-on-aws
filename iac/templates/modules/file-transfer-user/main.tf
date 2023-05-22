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

data "aws_ssm_parameter" "sftp_server_primary" {

  provider = aws.primary
  name     = "/${var.APP}/${var.ENV}/sftp_server"
}

data "aws_ssm_parameter" "sftp_server_secondary" {

  provider = aws.secondary
  name     = "/${var.APP}/${var.ENV}/sftp_server"
}

resource "aws_transfer_user" "primary_user" {

  provider = aws.primary

  server_id      = data.aws_ssm_parameter.sftp_server_primary.value
  user_name      = var.USER_NAME
  role           = var.ROLE_ARN
  home_directory = "/${var.PRIMARY_HOME_DIRECTORY}"
}

resource "aws_transfer_ssh_key" "primary_user" {

  provider = aws.primary

  server_id = data.aws_ssm_parameter.sftp_server_primary.value
  user_name = aws_transfer_user.primary_user.user_name
  body      = var.PUBLIC_KEY
}

resource "aws_transfer_user" "secondary_user" {

  provider = aws.secondary

  server_id      = data.aws_ssm_parameter.sftp_server_secondary.value
  user_name      = var.USER_NAME
  role           = var.ROLE_ARN
  home_directory = "/${var.SECONDARY_HOME_DIRECTORY}"
}

resource "aws_transfer_ssh_key" "secondary_user" {

  provider = aws.secondary

  server_id = data.aws_ssm_parameter.sftp_server_secondary.value
  user_name = aws_transfer_user.secondary_user.user_name
  body      = var.PUBLIC_KEY
}
