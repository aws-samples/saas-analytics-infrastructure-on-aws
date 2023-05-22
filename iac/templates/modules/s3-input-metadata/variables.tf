// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "RUNTIME" {
  default = "python3.8"
  type    = string
}

variable "LAMBDA_CODE_S3_BUCKET_ID" {
  description = "S3 bucket where the lambda function code is stored"
  type        = string
}

variable "LAMBDA_CODE_S3_BUCKET_KEY" {
  description = "S3 bucket file key for the lambda code"
  type        = string
}

variable "LAMBDA_HANDLER" {
  type = string
}

variable "SOURCE_CODE_HASH" {
  type = string
}

variable "S3_BUCKET_IDS" {
  description = "IDs of buckets to watch for s3:ObjectCreated:* events to trigger the metadata lambda"
  type        = list(string)
}

variable "DYNAMODB_TABLE_S3_FILE_INPUT" {
  description = "The name of the DynamoDB table that tracks S3 file input events"
  type        = string
}
