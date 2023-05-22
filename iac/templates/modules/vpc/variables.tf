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

variable "CIDR" {

  type = string
}

variable "PRIVATE_SUBNETS" {

  type = list(string)
}

variable "PUBLIC_SUBNETS" {

  type = list(string)
}
