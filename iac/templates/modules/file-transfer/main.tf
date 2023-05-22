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

locals {
  ROLE_NAME = "${var.APP}-${var.ENV}-AWSTransferLoggingAccess-role"
  ROLE_PATH = "/service-role/"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "transfer_logging_role" {

  count = var.CREATE_ROLE ? 1 : 0
  name  = local.ROLE_NAME
  path  = local.ROLE_PATH
  #permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "transfer.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "transfer_logging_role" {

  count = var.CREATE_ROLE ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSTransferLoggingAccess"
  role       = aws_iam_role.transfer_logging_role[0].name
}

resource "aws_security_group" "transfer_sg" {

  name        = "${var.APP}-${var.ENV}-transfer-sg"
  description = "${var.APP}-${var.ENV}-transfer-sg"
  vpc_id      = var.VPC_ID

  ingress {
    description     = "AWS Transfer Family SFTP"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = var.ALLOW_SFTP_CIDRS
    //    cidr_blocks = var.ALLOW_SFTP_CIDRS
  }

  tags = {
    Name = "${var.APP}-${var.ENV}-transfer-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
}

resource "aws_eip" "transfer" {

  vpc   = true
  count = 3
}

resource "aws_transfer_server" "sftp_server" {

  endpoint_type          = "VPC"
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role${local.ROLE_PATH}${local.ROLE_NAME}"
  protocols              = ["SFTP"]
  security_policy_name   = "TransferSecurityPolicy-FIPS-2020-06"
  domain                 = "S3"

  endpoint_details {
    address_allocation_ids = [aws_eip.transfer[0].id, aws_eip.transfer[1].id, aws_eip.transfer[2].id]
    subnet_ids             = var.SUBNET_IDS
    vpc_id                 = var.VPC_ID
    security_group_ids     = [aws_security_group.transfer_sg.id]
  }

  tags = {
    App = var.APP
    Env = var.ENV
  }
}

resource "aws_ssm_parameter" "sftp_server" {

  name        = "/${var.APP}/${var.ENV}/sftp_server"
  description = "The ${var.APP} SFTP server ID for the ${var.ENV} environment"
  type        = "SecureString"
  value       = aws_transfer_server.sftp_server.id
}
