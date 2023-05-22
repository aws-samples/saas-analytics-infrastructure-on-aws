// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "AWS_PRIMARY_REGION" {

  type = string
}

variable "AWS_SECONDARY_REGION" {

  type = string
}

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "APP_TITLE" {

  type = string
}

variable "ANALYTICS" {

  type = string
}

variable "STAGE" {

  type = string
}

variable "RUNTIME" {

  type = string
}

variable "CUSTOMER_IDS" {

  type = list(string)
}

variable "LAMBDA_PROVISIONED" {

  type = string
}
