// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

AWS_PRIMARY_REGION   = "###AWS_PRIMARY_REGION###"
AWS_SECONDARY_REGION = "###AWS_SECONDARY_REGION###"
APP                  = "###APP_NAME###"
ENV                  = "###ENV_NAME###"
CUSTOMER             = ###CUSTOMER_IDS_ARRAY###[1]
SFTP_USERS = [
  {
    name                = "customer2"
    home_directory_type = "output"
  }
]
