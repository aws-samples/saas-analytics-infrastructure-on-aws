// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "REGION" {

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

variable "ALLOWED_CALL_BACKS" {

  type = list(string)
}

variable "USER_POOL_NAME" {

  type = string
}

variable "IDENTITY_POOL_NAME" {

  type = string
}

variable "APP_TITLE" {

  type = string
}





