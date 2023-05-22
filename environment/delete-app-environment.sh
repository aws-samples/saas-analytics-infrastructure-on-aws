#!/usr/bin/env bash

# This script is a wizard that will delete an application environment
# for you by walking you through a guided series of questions

echo ""
echo "Welcome to the Delete Application Environment Wizard!"
echo ""

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $scriptDir/utility-functions.sh 1> /dev/null
validate_bash_version
source $scriptDir/../build-script/empty-s3.sh 1> /dev/null

echo "Note: This wizard does NOT delete a running application. Instead, it deletes the assets"
echo "that were created to support deploying your application to an isolated environment."
echo "Before deleting environment assets, you should delete the application itself from the"
echo "environment, such as by running \"terraform destroy\" or \"cdk destroy\" for example."
echo ""
echo "By continuing this wizard, you will be given a choice of which environment assets you"
echo "wish to delete."
echo ""
echo "Things that can be deleted by this wizard:"
echo "  * Environment variables set on remote stores such as AWS Parameter Store or GitLab CI"
echo "  * CICD pipeline IAM role CloudFormation stack"
echo "  * Terraform back end CloudFormation stack"
echo "  * CDK bootstrap CloudFormation stack"
echo "  * Local environment-<env>.json that holds the configurations for the environment"
echo ""

choose_local_environment deleteEnv "Which environment would you like to delete?"
yes_or_no deleteEnvSure "Are you sure you want to delete the \"$deleteEnv\" environment?" "n"
echo ""

if [[ "$deleteEnvSure" != "y" ]]; then
    exit 0
fi

origCurEnv=$(get_current_env)
set_current_env $deleteEnv

set_aws_cli_profile
validate_aws_cli_account

# Delete remote variables if applicable
if [[ "$REMOTE_ENV_VAR_LOC" == "ssm" ]]; then
    delete_ssm_remote_vars_for_env
elif [[ "$REMOTE_ENV_VAR_LOC" == "gitlab" ]]; then
    declare gitLabToken
    ask_gitlab_token gitLabToken ""
    
    if [[ -z "$gitLabToken" ]]; then
        echo "Skipping deleting environment data from GitLab."
    else 
        delete_gitlab_cicd_vars_for_env "$gitLabToken"
        delete_gitlab_cicd_environment "$gitLabToken"
    fi
fi

# Delete CICD pipeline IAM role if applicable
if [[ ! -z "$AWS_CREDS_TARGET_ROLE" ]]; then
    roleStackName="$APP_NAME-$ENV_NAME-cicd-role"
    echo ""
    yes_or_no deleteCicdRoleStack "Are you sure you want to delete the CICD pipeline IAM role CloudFormation stack \"$roleStackName\"?" "n"
    echo ""

    if [[ "$deleteCicdRoleStack" == "y" ]]; then
        echo ""
        echo "Deleting CloudFormation stack \"$roleStackName\" ..."
        aws cloudformation delete-stack --stack-name $roleStackName
        aws cloudformation wait stack-delete-complete --stack-name $roleStackName
        echo "  DONE Deleting CloudFormation stack \"$roleStackName\""
    fi
fi

# Delete Terraform backend if applicable
if [[ ! -z "$TF_S3_BACKEND_NAME" ]]; then
    tfStackName="$TF_S3_BACKEND_NAME"

    echo ""
    echo "WARNING: make sure that you have executed \"terraform destroy\""
    echo "to delete your application before you delete the Terraform back end"
    echo ""

    yes_or_no deleteTfBackendStack "Are you sure you want to delete the Terraform back end CloudFormation stack \"$tfStackName\"?" "n"
    echo ""

    if [[ "$deleteTfBackendStack" == "y" ]]; then
        empty_s3_bucket_by_name "$APP_NAME-$ENV_NAME-tf-back-end-$AWS_ACCOUNT_ID-$AWS_DEFAULT_REGION"
        echo ""
        echo "Deleting CloudFormation stack \"$tfStackName\" ..."
        aws cloudformation delete-stack --stack-name $tfStackName
        aws cloudformation wait stack-delete-complete --stack-name $tfStackName
        echo "  DONE Deleting CloudFormation stack \"$tfStackName\""
    fi
fi

# Delete CDK v2 bootstrap CloudFormation stack if applicable
cdkJsonFile=$(find $projectIacDir -type f -name 'cdk.json')
if [[ ! -z "$cdkJsonFile" ]]; then
    cdk2StackName="CDKToolkit"

    echo ""
    echo "WARNING: make sure that you have executed \"cdk destroy\""
    echo "to delete your application before you delete the CDK bootstap stack."
    echo "Do not delete the CDK bootstrap stack if other applications have"
    echo "been deployed to your account that utilize CDK."
    echo ""

    yes_or_no deleteCdk2BootstrapStack "Are you sure you want to delete the CDK v2 bootstrap CloudFormation stack \"$cdk2StackName\"?" "n"
    echo ""

    if [[ "$deleteCdk2BootstrapStack" == "y" ]]; then
        cdkBucketName="cdk-hnb659fds-assets-$AWS_ACCOUNT_ID-$AWS_DEFAULT_REGION"
        empty_s3_bucket_by_name "$cdkBucketName"
        echo ""
        echo "Deleting CDK v2 Bootstrap CloudFormation stack \"$cdk2StackName\" ..."
        aws cloudformation delete-stack --stack-name $cdk2StackName
        aws cloudformation wait stack-delete-complete --stack-name $cdk2StackName
        echo "  DONE Deleting CDK v2 Bootstrap CloudFormation stack \"$cdk2StackName\""
    fi
fi

# delete .environment-<env>.json file
curEnvFileName=$(get_env_var_file_name)
echo ""
yes_or_no deleteConfigSure "Are you sure you want to delete the local environment configuration file at \"$curEnvFileName\"?" "n"
echo ""

if [[ "$deleteConfigSure" == "y" ]]; then
    rm $curEnvFileName
    echo "DELETED: \"$curEnvFileName\""
    echo ""
fi

# check if deleted environment was the current environment
if [[ "$origCurEnv" != "$deleteEnv" ]]; then
    set_current_env $origCurEnv
    echo ""
    echo "Setting the current environment to \"$origCurEnv\"."
else
    localEnvNames=$(get_local_environment_names)

    if [[ -z "$localEnvNames" ]]; then
        echo ""
        echo "There are no local environments left. You will need to create a new one to continue working on this app."
        set_current_env "setme"
    else
        echo ""
        echo "The current environment has been deleted. Please choose another environment to make current."
        switch_local_environment
    fi
fi

echo ""
echo -e "${GREEN}Congratulations! The \"$deleteEnv\" environment has been deleted!${NC}"
echo ""