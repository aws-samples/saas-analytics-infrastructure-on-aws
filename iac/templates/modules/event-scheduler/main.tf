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

resource "aws_cloudwatch_event_rule" "analytics_event_rule" {

  name                = "${var.APP}-${var.ENV}-run-analytics-event-rule"
  description         = "Schedule ${var.APP_TITLE}"
  schedule_expression = "cron(59 23 * * ? *)"
  is_enabled          = var.IS_SCHEDULE_RULE_ENABLED
  tags = {
    App = var.APP
    Env = var.ENV
  }
}

resource "aws_cloudwatch_event_target" "analytics_event_lambda_target" {

  arn  = var.TARGET_LAMBDA_ARN
  rule = aws_cloudwatch_event_rule.analytics_event_rule.name
}

resource "aws_lambda_permission" "analytics_event_rule_invoke_lambda_permission" {

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.TARGET_LAMBDA_NAME
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.analytics_event_rule.arn
}
