// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role" {

  name = "${var.APP}-${var.ENV}-lambda-role"
  #permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {

  name        = "${var.APP}-${var.ENV}-lambda-policy"
  path        = "/"
  description = "${var.APP}-${var.ENV}-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "ec2:*",
          "iam:PassRole",
          "iam:CreateServiceLinkedRole",
          "kms:*",
          "lambda:*",
          "logs:*",
          "s3:*",
          "dynamodb:*",
          "cognito-idp:*",
          "secretsmanager:*",
          "ssm:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = [
          "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.APP}-${var.ENV}-analytics-execution"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {

  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_xray_policy_attachment" {

  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role" "api_role" {

  name = "${var.APP}-${var.ENV}-api-role"
  #permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_policy_attachment_1" {

  role       = aws_iam_role.api_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_iam_role_policy_attachment" "api_policy_attachment_2" {

  role       = aws_iam_role.api_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_role" "cloudwatch_role" {

  name = "${var.APP}-${var.ENV}-cloudwatch-role"
  #permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["apigateway.amazonaws.com","lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch_policy" {

  name = "${var.APP}-${var.ENV}-cloudwatch-policy"
  role = aws_iam_role.cloudwatch_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# BEGIN CREATING S3 INPUT FILE METADATA LAMBDA FUNCTION ROLE ################################

locals {
  metadata_s3_bucket_arns = concat(
    [for customerId in var.CUSTOMER_IDS : "arn:aws:s3:::${var.APP}-${var.ENV}-customer-input-${customerId}-primary/*"],
    [for customerId in var.CUSTOMER_IDS : "arn:aws:s3:::${var.APP}-${var.ENV}-customer-input-${customerId}-secondary/*"]
  )
  lambda_function_name = "${var.APP}-${var.ENV}-input-file-received"
  lambda_role_name     = "${var.APP}-${var.ENV}-s3-input-metadata-lambda-access"
}

data "aws_iam_policy_document" "metadata_lambda_trust_policy" {

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "metadata_lambda_access_policy" {

  statement {
    sid    = "CloudWatchLogsGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]

    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.APP}-${var.ENV}-input-file-received:*"
    ]
  }

  statement {
    sid    = "Analytics"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${var.APP}-${var.ENV}-file-events"
    ]
  }

  statement {
    sid    = "DecryptBucketObjects"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"
    ]
  }

  statement {
    sid    = "S3GetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]

    resources = local.metadata_s3_bucket_arns
  }

}

resource "aws_iam_role" "metadata_lambda" {

  assume_role_policy = data.aws_iam_policy_document.metadata_lambda_trust_policy.json
  name               = local.lambda_role_name
  path               = "/service-role/"
  inline_policy {
    name   = "MetadataLambdaAccess"
    policy = data.aws_iam_policy_document.metadata_lambda_access_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "metadatalambda_xray_policy_attachment" {

  role       = aws_iam_role.metadata_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "metadatalambda_vpc_policy_attachment" {

  role       = aws_iam_role.metadata_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# END CREATING S3 INPUT FILE METADATA LAMBDA FUNCTION ROLE ##################################
