// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

locals {
  mime_types = {
    "html" = "text/html"
    "txt"  = "text/html"
    "css"  = "text/css"
    "png"  = "text/html"
    "jpg"  = "text/html"
    "ico"  = "text/html"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/javascript"
  }
}

data "aws_ssm_parameter" "bucket_id" {

  name = "/${var.APP}/${var.ENV}/admin-dashboard-primary"
}

resource "aws_s3_object" "bucket_object" {

  for_each     = fileset(var.SOURCE_DIR, "**/*.*")
  bucket       = data.aws_ssm_parameter.bucket_id.value
  key          = each.value
  source       = "${var.SOURCE_DIR}${each.value}"
  etag         = filemd5("${var.SOURCE_DIR}${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}
