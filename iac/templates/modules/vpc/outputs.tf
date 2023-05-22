// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "name" {

  description = "The name of the VPC"
  value       = module.vpc.name
}

output "vpc_id" {

  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {

  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {

  description = "List of private subnets cyber blocks"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {

  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {

  description = "List of public subnets cyber blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}
