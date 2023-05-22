// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "RESOURCE_PREFIX" {

  type = string
}

variable "BUCKET_NAME_PRIMARY_REGION" {

  type = string
}

variable "BUCKET_NAME_SECONDARY_REGION" {

  type = string
}

variable "PRIMARY_CMK_ARN" {

  type = string
}

variable "SECONDARY_CMK_ARN" {

  type = string
}
