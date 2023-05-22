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

variable "PRIMARY_CIDR" {

  type = string
}

variable "PRIMARY_PRIVATE_SUBNETS" {

  type = list(string)
}

variable "PRIMARY_PUBLIC_SUBNETS" {

  type = list(string)
}

variable "SECONDARY_CIDR" {

  type = string
}

variable "SECONDARY_PRIVATE_SUBNETS" {

  type = list(string)
}

variable "SECONDARY_PUBLIC_SUBNETS" {

  type = list(string)

}

variable "ALLOW_SFTP_CIDRS" {

  type = list(string)
}
