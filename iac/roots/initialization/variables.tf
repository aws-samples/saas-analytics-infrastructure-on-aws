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

variable "API_USAGE" {

  type = string
}

variable "WHITE_LIST_IPS" {

  type = list(string)
}

variable "ADMIN_DISTRIBUTION_NAME" {

  type = string
}

variable "ADMIN_COMMENT" {

  type = string
}

variable "CUSTOMER_DISTRIBUTION_NAME" {

  type = string
}

variable "CUSTOMER_COMMENT" {

  type = string
}

variable "ADMIN_BUCKET_NAME_PRIMARY" {

  type = string
}

variable "ADMIN_BUCKET_NAME_SECONDARY" {

  type = string
}

variable "CUSTOMER_BUCKET_NAME_PRIMARY" {

  type = string
}

variable "CUSTOMER_BUCKET_NAME_SECONDARY" {

  type = string
}

variable "ADMIN_EMAIL" {

  type = string
}

variable "CUSTOMER1_EMAIL" {

  type = string
}

variable "CUSTOMER2_EMAIL" {

  type = string
}

variable "USER_POOL_NAME" {

  type = string
}

variable "IDENTITY_POOL_NAME" {

  type = string
}

variable "CUSTOMER_IDS" {

  type = list(string)
}

variable "APP_TITLE" {

  type = string
}
