#!/usr/bin/env bash

# This script allows you to configure dynamic lookups for placeholder resolution.
# For example, you can define a placeholder in a file and have it be resolved
# with a value that was retreived from the SSM Parameter Store. To accomplish
# this, you configure an association in this file between your placeholder
# and the path to lookup the value.
# Example:
# LOOKUPS[SSM_MYVAR]=/$APP_NAME/$ENV_NAME/someOptionalPath/myVar

declare -A LOOKUPS

LOOKUPS[SSM_DASHBOARD_ENDPOINT]=/$APP_NAME/$ENV_NAME/dashboard/api-endpoint
LOOKUPS[SSM_ANALYTICS1_ENDPOINT]=/$APP_NAME/$ENV_NAME/analytics1/api-endpoint
LOOKUPS[SSM_USER_POOL_ID]=/$APP_NAME/$ENV_NAME/cognito-user-pool-id
LOOKUPS[SSM_IDENTITY_POOL_ID]=/$APP_NAME/$ENV_NAME/cognito-identity-pool-id
LOOKUPS[SSM_WEB_CLIENT_ID]=/$APP_NAME/$ENV_NAME/cognito-app-client
LOOKUPS[SSM_CLOUDFRONT_DOMAIN]=/$APP_NAME/$ENV_NAME/admin/cloudfront-domain-name
