// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "USER_NAME" {

  type = string
}

variable "PUBLIC_KEY" {

  type = string
}

variable "ROLE_ARN" {

  type = string
}

variable "PRIMARY_HOME_DIRECTORY" {

  type        = string
  description = "primary region S3 bucket home directory"
}

variable "SECONDARY_HOME_DIRECTORY" {

  type        = string
  description = "secondary region S3 bucket home directory"
}
