// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "CREATE_ROLE" {

  type = bool
}

variable "VPC_ID" {

  type = string
}

variable "SUBNET_IDS" {

  type = list(string)
}

variable "ALLOW_SFTP_CIDRS" {

  type = list(string)
}

