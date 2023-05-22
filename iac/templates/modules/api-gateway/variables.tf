// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "RUNTIME" {

  type = string
}

variable "FUNCTION_NAME" {

  type = string
}

variable "CONCURRENCY" {

  type = number
}

variable "S3_BUCKET" {

  type = string
}

variable "S3_KEY" {

  type = string
}

variable "SOURCE_CODE_HASH" {

  type = string
}

variable "LAMBDA_HANDLER" {

  type = string
}

variable "LAMBDA_OPTIONS_HANDLER" {

  type = string
}

variable "LAMBDA_IAM_ROLE" {

  type = string
}

variable "API_IAM_ROLE" {

  type = string
}

variable "CLOUDWATCH_IAM_ROLE" {

  type = string
}

variable "SUBNET_IDS" {

  type = list(string)
}

variable "SECURITY_GROUP_IDS" {

  type = list(string)
}

variable "API_NAME" {

  type = string
}

variable "RESOURCE_NAME" {

  type = string
}

variable "METHOD_NAME" {

  type = string
}

variable "STAGE" {

  type = string
}


