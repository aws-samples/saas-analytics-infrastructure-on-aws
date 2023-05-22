// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
  }
}

resource "aws_wafv2_ip_set" "ip_white_list" {

  name               = "${var.APP}-${var.ENV}-${var.USAGE}-ip-white-list"
  description        = "${var.APP}-${var.ENV}-${var.USAGE}-ip-white-list"
  scope              = var.SCOPE
  ip_address_version = "IPV4"
  addresses          = var.WHITE_LIST_IPS
}

resource "aws_wafv2_web_acl" "waf_acl" {

  name        = "${var.APP}-${var.ENV}-${var.USAGE}"
  description = "${var.APP}-${var.ENV}-${var.USAGE}"
  scope       = var.SCOPE

  default_action {
    allow {}
  }

  //  rule {
  //    name     = "rule-1"
  //    priority = 1
  //
  //    action {
  //      allow {}
  //    }
  //
  //    statement {
  //      ip_set_reference_statement {
  //        arn = aws_wafv2_ip_set.ip_white_list.arn
  //      }
  //    }
  //
  //    visibility_config {
  //      cloudwatch_metrics_enabled = false
  //      metric_name                = "WhiteListIPs"
  //      sampled_requests_enabled   = false
  //    }
  //  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "WhiteListIPs"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "Blocked"
    sampled_requests_enabled   = false
  }

  #checkov:skip=CKV2_AWS_31: "Ensure WAF2 has a Logging Configuration"
}

resource "aws_ssm_parameter" "waf_acl_arn" {

  name        = "/${var.APP}/${var.ENV}/${var.USAGE}/waf-acl-arn"
  description = "The WAF ACL ARN"
  type        = "SecureString"
  value       = aws_wafv2_web_acl.waf_acl.arn
}
