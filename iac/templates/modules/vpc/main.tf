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

module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "${var.APP}-${var.ENV}-vpc"
  cidr = var.CIDR

  azs             = ["${var.AWS_PRIMARY_REGION}a", "${var.AWS_PRIMARY_REGION}b", "${var.AWS_PRIMARY_REGION}c"]
  private_subnets = var.PRIVATE_SUBNETS
  public_subnets  = var.PUBLIC_SUBNETS

  create_igw         = true
  enable_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    App = var.APP
    Env = var.ENV
  }
}

resource "aws_ssm_parameter" "vpc" {

  name        = "/${var.APP}/${var.ENV}/vpc"
  description = "The VPC ID"
  type        = "SecureString"
  value       = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_1" {

  name        = "/${var.APP}/${var.ENV}/public-subnet-1"
  description = "The Public Subnet 1"
  type        = "SecureString"
  value       = module.vpc.public_subnets[0]
}

resource "aws_ssm_parameter" "public_subnet_2" {

  name        = "/${var.APP}/${var.ENV}/public-subnet-2"
  description = "The Public Subnet 2"
  type        = "SecureString"
  value       = module.vpc.public_subnets[1]
}

resource "aws_ssm_parameter" "public_subnet_3" {

  name        = "/${var.APP}/${var.ENV}/public-subnet-3"
  description = "The Public Subnet 3"
  type        = "SecureString"
  value       = module.vpc.public_subnets[2]
}

resource "aws_ssm_parameter" "private_subnet_1" {

  name        = "/${var.APP}/${var.ENV}/private-subnet-1"
  description = "The Private Subnet 1"
  type        = "SecureString"
  value       = module.vpc.private_subnets[0]
}

resource "aws_ssm_parameter" "private_subnet_2" {

  name        = "/${var.APP}/${var.ENV}/private-subnet-2"
  description = "The Private Subnet 2"
  type        = "SecureString"
  value       = module.vpc.private_subnets[1]
}

resource "aws_ssm_parameter" "private_subnet_3" {

  name        = "/${var.APP}/${var.ENV}/private-subnet-3"
  description = "The Private Subnet 3"
  type        = "SecureString"
  value       = module.vpc.private_subnets[2]
}

data "aws_route_table" "public_subnet_1_route_table" {

  subnet_id = module.vpc.public_subnets[0]
}

data "aws_route_table" "private_subnet_1_route_table" {

  subnet_id = module.vpc.private_subnets[0]
}

data "aws_route_table" "private_subnet_2_route_table" {

  subnet_id = module.vpc.private_subnets[1]
}

data "aws_route_table" "private_subnet_3_route_table" {

  subnet_id = module.vpc.private_subnets[2]
}

resource "aws_ssm_parameter" "public_subnet_1_route_table_id" {

  name        = "/${var.APP}/${var.ENV}/public-subnet-1-route-table-id"
  description = "The Public Subnet 1 Route Table ID"
  type        = "SecureString"
  value       = data.aws_route_table.public_subnet_1_route_table.id
}

resource "aws_ssm_parameter" "private_subnet_1_route_table_id" {

  name        = "/${var.APP}/${var.ENV}/private-subnet-1-route-table-id"
  description = "The Private Subnet 1 Route Table ID"
  type        = "SecureString"
  value       = data.aws_route_table.private_subnet_1_route_table.id
}

resource "aws_ssm_parameter" "private_subnet_2_route_table_id" {

  name        = "/${var.APP}/${var.ENV}/private-subnet-2-route-table-id"
  description = "The Private Subnet 2 Route Table ID"
  type        = "SecureString"
  value       = data.aws_route_table.private_subnet_2_route_table.id
}

resource "aws_ssm_parameter" "private_subnet_3_route_table_id" {

  name        = "/${var.APP}/${var.ENV}/private-subnet-3-route-table-id"
  description = "The Private Subnet 3 Route Table ID"
  type        = "SecureString"
  value       = data.aws_route_table.private_subnet_3_route_table.id
}

resource "aws_security_group" "lambda_sg" {

  name        = "${var.APP}-${var.ENV}-lambda-sg"
  description = "${var.APP}-${var.ENV}-lambda-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH Port from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.CIDR]
  }

  ingress {
    description     = "SSH Port from AWS Corp"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = (var.AWS_PRIMARY_REGION == "us-east-1") ? ["pl-4e2ece27"] : ["pl-5aa44133"]
  }

  ingress {
    description = "HTTP Port from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.CIDR]
  }

  ingress {
    description     = "HTTP Port from AWS Corp"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = (var.AWS_PRIMARY_REGION == "us-east-1") ? ["pl-4e2ece27"] : ["pl-5aa44133"]
  }

  ingress {
    description = "HTTPS Port from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.CIDR]
  }

  ingress {
    description     = "HTTPS Port from AWS Corp"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = (var.AWS_PRIMARY_REGION == "us-east-1") ? ["pl-4e2ece27"] : ["pl-5aa44133"]
  }

  egress {
    description = "Egress Ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP}-${var.ENV}-lambda-sg"
  }

  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
}

resource "aws_ssm_parameter" "lambda_sg" {

  name        = "/${var.APP}/${var.ENV}/lambda-sg"
  description = "The lambda security group"
  type        = "SecureString"
  value       = aws_security_group.lambda_sg.id
}
