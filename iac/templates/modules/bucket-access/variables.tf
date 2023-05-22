// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "READ_BUCKET_ARNS" {
  type        = set(string)
  description = "A set of S3 bucket ARNs that require read access"
}

variable "WRITE_BUCKET_ARNS" {
  type        = set(string)
  description = "A set of S3 bucket ARNs that require write access"
}

variable "RESOURCE_PREFIX" {
  type = string
}

variable "PRIMARY_CMK_ARN" {

  type = string
}

variable "SECONDARY_CMK_ARN" {

  type = string
}
