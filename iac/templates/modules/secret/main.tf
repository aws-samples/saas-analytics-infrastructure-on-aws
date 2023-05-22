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

data "aws_kms_key" "secret_manager_secret_key" {

  key_id = "alias/${var.APP}-${var.ENV}-secret-manager-secret-key"
}

resource "aws_secretsmanager_secret" "secret" {

  name       = "${var.APP}-${var.ENV}-${var.NAME}"
  kms_key_id = data.aws_kms_key.secret_manager_secret_key.key_id
  replica {
    region = var.AWS_SECONDARY_REGION
  }
  recovery_window_in_days        = 0
  force_overwrite_replica_secret = true
}

resource "aws_secretsmanager_secret_version" "secret-version" {

  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.VALUE
}
