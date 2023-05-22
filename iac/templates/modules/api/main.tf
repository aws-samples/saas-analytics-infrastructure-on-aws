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

resource "aws_api_gateway_rest_api" "api" {

  name        = "${var.APP}-${var.ENV}-${var.API_NAME}"
  description = var.API_NAME

  lifecycle {
    create_before_destroy = true
  }

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

data "aws_ssm_parameter" "cognito_user_pool_arn" {

  name = "/${var.APP}/${var.ENV}/cognito-user-pool-arn"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {

  name            = "${var.APP}-${var.ENV}-${var.API_NAME}-cognito-authorizer"
  identity_source = "method.request.header.authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [data.aws_ssm_parameter.cognito_user_pool_arn.value]
  rest_api_id     = aws_api_gateway_rest_api.api.id
}

