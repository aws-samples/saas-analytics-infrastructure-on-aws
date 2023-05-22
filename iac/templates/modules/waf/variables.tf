// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "USAGE" {

  type = string
}

variable "SCOPE" {

  type = string
}

variable "WHITE_LIST_IPS" {

  type = list(string)
}
