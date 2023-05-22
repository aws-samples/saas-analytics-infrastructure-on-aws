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

resource "aws_kms_key" "key" {

  description         = var.DESCRIPTION
  enable_key_rotation = true

  tags = {
    Name = var.NAME
  }
}

resource "aws_kms_alias" "key_alias" {

  name          = "alias/${var.NAME}"
  target_key_id = aws_kms_key.key.key_id
}
