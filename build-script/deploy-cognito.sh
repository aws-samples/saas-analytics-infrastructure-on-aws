#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m' # No Color

get_random_pw () {
    local rpw
    local lower="[a-z]+"
    local upper="[A-Z]+"
    rpw=$(openssl rand -base64 6)
    while true
    do
        rpw=$(openssl rand -base64 6)
        [[ $rpw =~ $lower ]] && [[ $rpw =~ $upper ]] && echo "$rpw" && return 0
        # uncomment for debugging:
        # echo "bad password: \"$rpw\"" >&2
    done
}

echo ""
echo "Deploying Cognito Configuration..."
password1=$(get_random_pw)
aws ssm --region us-east-1 put-parameter --name /###APP_NAME###/###ENV_NAME###/admin-password --value $password1 --type "String" --overwrite
password2=$(get_random_pw)
aws ssm --region us-west-2 put-parameter --name /###APP_NAME###/###ENV_NAME###/admin-password --value $password2 --type "String" --overwrite
password3=$(get_random_pw)
aws ssm --region us-east-1 put-parameter --name /###APP_NAME###/###ENV_NAME###/customer1-password --value $password3 --type "String" --overwrite
password4=$(get_random_pw)
aws ssm --region us-west-2 put-parameter --name /###APP_NAME###/###ENV_NAME###/customer1-password --value $password4 --type "String" --overwrite
password5=$(get_random_pw)
aws ssm --region us-east-1 put-parameter --name /###APP_NAME###/###ENV_NAME###/customer2-password --value $password5 --type "String" --overwrite
password6=$(get_random_pw)
aws ssm --region us-west-2 put-parameter --name /###APP_NAME###/###ENV_NAME###/customer2-password --value $password6 --type "String" --overwrite
primaryUserPoolId=$(aws ssm --region us-east-1 get-parameter --name /###APP_NAME###/###ENV_NAME###/cognito-user-pool-id --with-decryption --query Parameter.Value --output text)
secondaryUserPoolId=$(aws ssm --region us-west-2 get-parameter --name /###APP_NAME###/###ENV_NAME###/cognito-user-pool-id --with-decryption --query Parameter.Value --output text)

aws cognito-idp admin-set-user-password --region us-east-1 --user-pool-id $primaryUserPoolId --username ###ADMIN_IDP_EMAIL### --password $password1 --permanent || { cognitoFailure="true"; }
aws cognito-idp admin-set-user-password --region us-west-2 --user-pool-id $secondaryUserPoolId --username ###ADMIN_IDP_EMAIL### --password $password2 --permanent || { cognitoFailure="true"; }
aws cognito-idp admin-set-user-password --region us-east-1 --user-pool-id $primaryUserPoolId --username ###CUSTOMER1_IDP_EMAIL### --password $password3 --permanent || { cognitoFailure="true"; }
aws cognito-idp admin-set-user-password --region us-west-2 --user-pool-id $secondaryUserPoolId --username ###CUSTOMER1_IDP_EMAIL### --password $password4 --permanent || { cognitoFailure="true"; }
aws cognito-idp admin-set-user-password --region us-east-1 --user-pool-id $primaryUserPoolId --username ###CUSTOMER2_IDP_EMAIL### --password $password5 --permanent || { cognitoFailure="true"; }
aws cognito-idp admin-set-user-password --region us-west-2 --user-pool-id $secondaryUserPoolId --username ###CUSTOMER2_IDP_EMAIL### --password $password6 --permanent || { cognitoFailure="true"; }

echo "Finished Deploying Cognito Configuration"

if [[ "$cognitoFailure" == "true" ]]; then
    echo -e "${RED} ERROR: One or more Cognito passwords could not be set.${NC}" >&2
    exit 1
fi