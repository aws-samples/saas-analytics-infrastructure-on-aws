// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "APP_TITLE" {

  type = string
}

variable "IS_SCHEDULE_RULE_ENABLED" {
  description = "Set to true if the event bridge scheduling rule should be enabled"
  type        = bool
}

variable "TARGET_LAMBDA_ARN" {
  description = "ARN of the lambda function to call when the scheduled event fires"
  type        = string
}

variable "TARGET_LAMBDA_NAME" {
  description = "Name of the lambda function to call when the scheduled event fires"
  type        = string
}
