// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "waf_acl_id" {

  description = "The WAF ACL ID"
  value       = aws_wafv2_web_acl.waf_acl.id
}

output "waf_acl_arn" {

  description = "The WAF ACL ARN"
  value       = aws_wafv2_web_acl.waf_acl.arn
}
