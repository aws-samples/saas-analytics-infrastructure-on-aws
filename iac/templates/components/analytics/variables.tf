// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "AWS_PRIMARY_REGION" {

  type = string
}

variable "AWS_SECONDARY_REGION" {

  type = string
}

variable "REGION_ID" {

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

variable "PRIMARY_KMS_KEY_ARN" {

  type = string
}

variable "SECONDARY_KMS_KEY_ARN" {

  type = string
}

variable "PATH" {

  type = string
}

variable "STAGE" {

  type = string
}

variable "RUNTIME" {

  type = string
}

variable "IS_ACTIVE_DR_REGION" {
  description = "Set to true if the region supplied to this module is the primary region in a disaster recovery plan or if using an active/active DR strategy"
  type        = bool
}

variable "CUSTOMER_IDS" {

  type = list(string)
}

variable "DYNAMODB_TABLE_S3_FILE_INPUT" {
  description = "The name of the DynamoDB table that tracks S3 analytics file input events"
  type        = string
}

variable "LAMBDA_PROVISIONED" {

  type = string
}
