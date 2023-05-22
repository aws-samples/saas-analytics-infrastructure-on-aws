// Copyright 2022 Amazon.com and its affiliates; all rights reserved.
// SPDX-License-Identifier: MIT No Attribution

output "sftp_server_id" {

  description = "The ID of the SFTP server"
  value       = aws_transfer_server.sftp_server.id
}
