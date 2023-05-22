// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "API_NAME" {

  type = string
}

variable "API_ID" {

  type = string
}

variable "CLOUDWATCH_IAM_ROLE" {

  type = string
}

variable "DEPLOYMENT_TRIGGER" {

  type = string
}

variable "STAGE" {

  type = string
}

variable "METHODS" {

  type = list(string)
}





