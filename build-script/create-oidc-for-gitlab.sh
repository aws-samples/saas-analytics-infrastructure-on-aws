#!/usr/bin/env bash

# Optional script that could be used for deploying this project via a GitLab
# CICD pipeline.
#
# This script will create an OIDC provider for ID federation between GitLab and AWS.
# If these commands do not work on your machine, you may find it much easier to create
# the OIDC provider from the AWS Web Console. 
# See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html#manage-oidc-provider-console

# Example IAM Assume Role Configuration:
# {
#     "Sid": "GitLabCICDFederation",
#     "Effect": "Allow",
#     "Principal": {
#         "Federated": "arn:aws:iam::ACCOUNT_PLACEHOLDER:oidc-provider/gitlab.com"
#     },
#     "Action": "sts:AssumeRoleWithWebIdentity",
#     "Condition": {
#         "StringLike": {
#             "gitlab.com:sub": "project_path:mygroup/myproject:ref_type:branch:ref:*"
#         }
#     }
# }

GITLAB_DOMAIN=gitlab.com

# Generate thumbprint for Gitlab
openssl s_client -servername $GITLAB_DOMAIN -showcerts -connect $GITLAB_DOMAIN:443 </dev/null | sed -n -e '/-.BEGIN/,/-.END/ p' | tac | sed '/.*BEGIN CERTIFICATE.*/q' | tac > certificate.crt
THUMBPRINT=$(openssl x509 -in certificate.crt -fingerprint -noout | sed 's/SHA1 Fingerprint=//' | sed 's/://g')
rm ./certificate.crt

aws iam create-open-id-connect-provider --url https://$GITLAB_DOMAIN --thumbprint-list "$THUMBPRINT" --client-id-list "https://$GITLAB_DOMAIN"
