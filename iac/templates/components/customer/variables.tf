// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

variable "APP" {

  type = string
}

variable "ENV" {

  type = string
}

variable "CUSTOMER" {

  type = string
}

variable "PRIMARY_KMS_KEY_ARN" {

  type = string
}

variable "SECONDARY_KMS_KEY_ARN" {

  type = string
}

variable "SFTP_USERS" {
  type = list(object({
    name                = string
    home_directory_type = string
    public_key          = string
  }))

  validation {
    condition = (
      alltrue([for user in var.SFTP_USERS : (
        length(user.name) > 0
        && length(user.public_key) > 0
        && contains(["input", "output"], user.home_directory_type)
      )])
    )
    error_message = "Validation of an SFTP_USERS object failed."
  }
}
