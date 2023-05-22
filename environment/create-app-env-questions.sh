#!/usr/bin/env bash

# This script holds reusable "create app" and "create app environment"
# questions that can be asked by a wizard.

# Puts Create App Wizard choices into an array for later caching use
populate_create_app_choice_cache_array () {
    [[ ! -z "$projectParentDir" ]] && choiceCacheArray+=("defaultProjectParentDir=${projectParentDir}")
    [[ ! -z "$gitProjectGroup" ]] && choiceCacheArray+=("defaultGitProjectGroup=${gitProjectGroup}")
    [[ ! -z "$gitProjectName" ]] && choiceCacheArray+=("defaultGitProjectName=${gitProjectName}")
    [[ ! -z "$gitRepoDomain" ]] && choiceCacheArray+=("defaultGitRepoDomain=${gitRepoDomain}")
    [[ ! -z "$gitRepoProvider" ]] && choiceCacheArray+=("defaultGitRepoProvider=${gitRepoProvider}")
    [[ ! -z "$APP_NAME" ]] && choiceCacheArray+=("defaultAppName=${APP_NAME}")
    [[ ! -z "$ENABLE_ONCE_PER_ACCOUNT_RESOURCES" ]] && choiceCacheArray+=("defaultEnableOncePerAccount=${ENABLE_ONCE_PER_ACCOUNT_RESOURCES}")
    [[ ! -z "$ENV_NAME" ]] && choiceCacheArray+=("defaultEnvName=${ENV_NAME}")
    [[ ! -z "$CREATED_BY" ]] && choiceCacheArray+=("defaultCreatedBy=${CREATED_BY}")
    [[ ! -z "$AWS_ACCOUNT_ID" ]] && choiceCacheArray+=("defaultAwsAccountNum=${AWS_ACCOUNT_ID}")
    [[ ! -z "$AWS_DEFAULT_REGION" ]] && choiceCacheArray+=("defaultRegion=${AWS_DEFAULT_REGION}")
    [[ ! -z "$AWS_SECONDARY_REGION" ]] && choiceCacheArray+=("defaultSecondaryRegion=${AWS_SECONDARY_REGION}")
    [[ ! -z "$iac" ]] && choiceCacheArray+=("defaultIaC=${iac}")
    [[ ! -z "$useCicd" ]] && choiceCacheArray+=("defaultUseCicd=${useCicd}")
    [[ ! -z "$useCodeCommitMirror" ]] && choiceCacheArray+=("defaultUseCodeCommitMirror=${useCodeCommitMirror}")
    [[ ! -z "$useSonarQube" ]] && choiceCacheArray+=("defaultUseSonarQube=${useSonarQube}")
    [[ ! -z "$cicd" ]] && choiceCacheArray+=("defaultCicd=${cicd}")
    [[ ! -z "$genEnvUtils" ]] && choiceCacheArray+=("defaultGenEnvUtils=${genEnvUtils}")
    [[ ! -z "$deployCodeCommitPushMirror" ]] && choiceCacheArray+=("defaultDeployCodeCommitPushMirror=${deployCodeCommitPushMirror}")
    [[ ! -z "$deployRole" ]] && choiceCacheArray+=("defaultDeployRole=${deployRole}")
    [[ ! -z "$deployRemoteEnvVars" ]] && choiceCacheArray+=("defaultDeployRemoteEnvVars=${deployRemoteEnvVars}")
    [[ ! -z "$REMOTE_ENV_VAR_LOC" ]] && choiceCacheArray+=("defaultRemoteEnvVarLoc=${REMOTE_ENV_VAR_LOC}")
    [[ ! -z "$deployTfBackend" ]] && choiceCacheArray+=("defaultDeployTfBackend=${deployTfBackend}")
    [[ ! -z "$deployCdk2Backend" ]] && choiceCacheArray+=("defaultDeployCdk2Backend=${deployCdk2Backend}")
    [[ ! -z "$SONAR_HOST_URL" ]] && choiceCacheArray+=("defaultSonarQubeHostUrl=${SONAR_HOST_URL}")
    [[ ! -z "$hasSecondaryRegion" ]] && choiceCacheArray+=("defaultHasSecondaryRegion=${hasSecondaryRegion}")
}

# Puts Create App Environment Wizard choices into an array for later caching use
populate_create_app_env_choice_cache_array () {
    [[ ! -z "$useEnvWithCicd" ]] && choiceEnvCacheArray+=("defaultUseEnvWithCicd=${useEnvWithCicd}")
    [[ ! -z "$APP_NAME" ]] && choiceEnvCacheArray+=("defaultAppName=${APP_NAME}")
    [[ ! -z "$CREATED_BY" ]] && choiceEnvCacheArray+=("defaultCreatedBy=${CREATED_BY}")
    [[ ! -z "$AWS_ACCOUNT_ID" ]] && choiceEnvCacheArray+=("defaultAwsAccountNum=${AWS_ACCOUNT_ID}")
    [[ ! -z "$AWS_DEFAULT_REGION" ]] && choiceEnvCacheArray+=("defaultRegion=${AWS_DEFAULT_REGION}")
    [[ ! -z "$AWS_SECONDARY_REGION" ]] && choiceEnvCacheArray+=("defaultSecondaryRegion=${AWS_SECONDARY_REGION}")
    [[ ! -z "$deployRole" ]] && choiceEnvCacheArray+=("defaultDeployRole=${deployRole}")
    [[ ! -z "$deployRemoteEnvVars" ]] && choiceEnvCacheArray+=("defaultDeployRemoteEnvVars=${deployRemoteEnvVars}")
    [[ ! -z "$REMOTE_ENV_VAR_LOC" ]] && choiceEnvCacheArray+=("defaultRemoteEnvVarLoc=${REMOTE_ENV_VAR_LOC}")
    [[ ! -z "$deployTfBackend" ]] && choiceEnvCacheArray+=("defaultDeployTfBackend=${deployTfBackend}")
    [[ ! -z "$deployCdk2Backend" ]] && choiceEnvCacheArray+=("defaultDeployCdk2Backend=${deployCdk2Backend}")
    [[ ! -z "$SONAR_HOST_URL" ]] && choiceEnvCacheArray+=("defaultSonarQubeHostUrl=${SONAR_HOST_URL}")
}

# adds hasSecondaryRegion to global namespace
ask_if_has_secondary_region () {
    local defaultHasSecondaryRegion=$(echo $choiceCacheJson | jq -r '.defaultHasSecondaryRegion | select(type == "string")')
    defaultHasSecondaryRegion="${defaultHasSecondaryRegion:=n}"

    echo ""
    yes_or_no hasSecondaryRegion "Will components of your application be deployed to a secondary region" "$defaultHasSecondaryRegion"
}

# adds useEnvWithCicd to global namespace
ask_if_use_new_environment_with_cicd_pipeline () {
    local defaultUseEnvWithCicd=n
    echo ""
    yes_or_no useEnvWithCicd "Do you want to use your environment from a CICD pipeline" "$defaultUseEnvWithCicd"
}

# adds createRemoteGitRepo to global namespace
ask_if_create_git_repo () {
    if [[ "$paceAppGitDirExists" == "y" ]]; then
        createRemoteGitRepo="n"
        return 0
    fi

    local defaultCreateRemoteGitRepo=n
    echo ""
    yes_or_no createRemoteGitRepo "Create a Git repository for your project if it does not exist" "$defaultCreateRemoteGitRepo"
    # Note - this choice is deliberately not stored in the wizard choice cache
}

# adds gitRepoProvider to global namespace
optionally_ask_which_git_repo_provider () {
    if [[ "$paceAppGitDirExists" != "y" ]] && [[ "$createRemoteGitRepo" == "y" ]]; then
        echo ""
        local defaultGitRepoProvider=$(echo $choiceCacheJson | jq -r '.defaultGitRepoProvider | select(type == "string")')
        defaultGitRepoProvider="${defaultGitRepoProvider:=gitlab}"
        echo "Which Git provider will your project use?"
        gitRepoProvider=$(select_with_default "GitLab|CodeCommit" "gitlab|codecommit" "$defaultGitRepoProvider")
        if [[ "$gitRepoProvider" == "codecommit" ]]; then
            gitProjectGroup="codecommit"
        fi
    fi
}

# adds gitRepoDomain to global namespace
# param1: default git repo domain
ask_git_repo_domain () {
    local paramRepoDefault="$1"
    echo ""
    local defaultGitRepoDomain=$(echo $choiceCacheJson | jq -r '.defaultGitRepoDomain | select(type == "string")')
    if [[ -z "$defaultGitRepoDomain" ]]; then
        defaultGitRepoDomain="$paramRepoDefault"
    fi
    length_range gitRepoDomain "Enter the Git repository domain:" \
    "$defaultGitRepoDomain" "1" "60"
}

# adds gitRepoDomain to global namespace
ask_codecommit_repo_domain () {
    echo ""

    if ! command -v which git-remote-codecommit &> /dev/null
    then
        echo ""
        echo -e "${YELLOW} WARN: git-remote-codecommit not found.${NC}" >&2
        echo "git-remote-codecommit is required if you want to use the HTTPs (GRC) method to connect to CodeCommit."
        echo "git-remote-codecommit can be installed with the following command: pip install git-remote-codecommit"
        echo ""
    fi

    local defaultGitRepoDomain=""
    echo "Enter the CodeCommit repository domain:"
    local ccDescriptions="codecommit::$AWS_DEFAULT_REGION://$APP_NAME (HTTPS GRC)|ssh://git-codecommit.$AWS_DEFAULT_REGION.amazonaws.com/v1/repos/$APP_NAME (SSH)|https://git-codecommit.$AWS_DEFAULT_REGION.amazonaws.com/v1/repos/$APP_NAME (HTTPS)"
    local ccValues="codecommit::$AWS_DEFAULT_REGION://$APP_NAME|ssh://git-codecommit.$AWS_DEFAULT_REGION.amazonaws.com/v1/repos/$APP_NAME|https://git-codecommit.$AWS_DEFAULT_REGION.amazonaws.com/v1/repos/$APP_NAME"
    gitRepoDomain=$(select_with_default "$ccDescriptions" "$ccValues")
}

# adds gitRepoDomain to global namespace
# param1: default git repo domain
optionally_ask_git_repo_domain () {
    if [[ ! -z "$gitRepoDomain" ]]; then
        return
    fi

    if [[ "$gitRepoProvider" == "codecommit" ]]; then
        ask_codecommit_repo_domain
    elif [[ "$createRemoteGitRepo" == "y" ]] || [[ "$cicd" == "gitlab" ]]; then
        ask_git_repo_domain $1
    fi
}

# adds gitProjectGroup to global namespace
# param1: the default value of the Git project group
ask_git_project_group () {
    if [[ "$paceAppGitDirExists" == "y" ]]; then
        return 0
    fi
    echo ""
    local defaultGitProjectGroup=$(echo $choiceCacheJson | jq -r '.defaultGitProjectGroup | select(type == "string")')
    if [[ -z "$defaultGitProjectGroup" ]]; then
        defaultGitProjectGroup="$1"
    fi
    length_range gitProjectGroup "Enter the GitLab repository group/namespace:" \
    "$defaultGitProjectGroup" "1" "50"
}

# param1: the default value of the Git project group
optionally_ask_git_project_group () {
    if [[ ! -z "$gitProjectGroup" ]]; then
        return 0
    fi

    if [[ "$createRemoteGitRepo" == "y" ]] || [[ "$cicd" == "gitlab" ]]; then
        ask_git_project_group "$1"
    fi
}

# adds gitProjectName to global namespace
ask_git_project_name () {
    echo ""
    local defaultGitProjectName=$(echo $choiceCacheJson | jq -r '.defaultGitProjectName | select(type == "string")')
    length_range gitProjectName \
    "Enter the application name. A directory will be created later on your computer based upon this name if it does not already exist:" "$defaultGitProjectName" "1" "75"
}

# adds APP_NAME to global namespace
ask_app_name () {
    echo ""
    echo The application name should be short since it is often used
    echo as a prefix to an AWS resource identifier.
    local defaultAppName=$(echo $choiceCacheJson | jq -r '.defaultAppName | select(type == "string")')
    defaultAppName="${defaultAppName:=$gitProjectName}"
    length_range APP_NAME "Enter the app name:" "$defaultAppName" "1" "10"
}

# adds ENV_NAME to global namespace
# pass in "ignoreDefault" as the first argument if you do not want to
# suggest a default value
ask_environment_name () {
    # Optional param to not use a default value
    local ignoreDefault=$1

    echo ""
    echo The deployment environment name should be short since it is 
    echo often used as part of an AWS resource identifier.
    echo Use your initials if the environment is just for you or use
    echo traditional names like \"dev\" or \"qa\" for shared environments
    local defaultEnvName=""
    if [[ "$ignoreDefault" != "ignoreDefault" ]]; then
        defaultEnvName=$(echo $choiceCacheJson | jq -r '.defaultEnvName | select(type == "string")')
    fi
    length_range ENV_NAME "Enter an environment name:" "$defaultEnvName" "1" "6"
}

# adds ENABLE_ONCE_PER_ACCOUNT_RESOURCES to global namespace
ask_enable_once_per_account_resources () {
    echo ""
    echo "Your application may or may not have resources that should only be deployed"
    echo "once per AWS account (as opposed to once per application environment). For"
    echo "example, you might want to deploy an RDS database once in an account and"
    echo "then deploy a \"dev\" and \"qa\" application environment to that same"
    echo "account, where both application environments share the same RDS database."
    echo "To make this work, you must read the \"ENABLE_ONCE_PER_ACCOUNT_RESOURCES\""
    echo "setting in your IaC code (Terraform\CDK\Cloudformation) so that your IaC"
    echo "code knows whether or not to create the RDS database. \"Once-per-account\""
    echo "resources will be named with the application name as a qualifier. This is"
    echo "in contrast to the default resource name qualifier that includes both the"
    echo "application name and the environment name."
    echo ""
    local defaultEnableOncePerAccount="n"
    if [[ "$CREATE_APP" == "true" ]]; then
        defaultEnableOncePerAccount=$(echo $choiceCacheJson | jq -r '.defaultEnableOncePerAccount | select(type == "string")')
        defaultEnableOncePerAccount="${defaultEnableOncePerAccount:=y}"
    fi
    if [[ "$defaultEnableOncePerAccount" == "true" ]]; then
        defaultEnableOncePerAccount=y
    else
        defaultEnableOncePerAccount=n
    fi
    yes_or_no ENABLE_ONCE_PER_ACCOUNT_RESOURCES "Do you want to use the \"$ENV_NAME\" environment for deploying \"once per AWS account\" application resources?" "$defaultEnableOncePerAccount"
    if [[ "$ENABLE_ONCE_PER_ACCOUNT_RESOURCES" == "y" ]]; then
        ENABLE_ONCE_PER_ACCOUNT_RESOURCES=true
    else
        ENABLE_ONCE_PER_ACCOUNT_RESOURCES=false
    fi
}

# adds CREATED_BY to global namespace
ask_created_by () {
    echo ""
    local defaultCreatedBy=$(echo $choiceCacheJson | jq -r '.defaultCreatedBy | select(type == "string")')
    if [[ -z "$defaultCreatedBy" ]]; then
        defaultCreatedBy=$(whoami)
    fi
    length_range CREATED_BY "Enter your name to mark the \"$ENV_NAME\" environment as yours:" "$defaultCreatedBy" "1" "90" "allowWhitespace"
}

optionally_ask_created_by () {
    if [[ "$REMOTE_ENV_VAR_LOC" != "na" ]]; then
        ask_created_by
    fi
}

# adds AWS_ACCOUNT_ID to global namespace
# adds awsDeployDisabled to the global namespace
ask_aws_account_number () {
    echo ""
    local defaultAwsAccountNum=$(echo $choiceCacheJson | jq -r '.defaultAwsAccountNum | select(type == "string")')
    aws_account_number AWS_ACCOUNT_ID "Enter the AWS account number used to host the environment or enter all 0's if you do not have an account yet:" "$defaultAwsAccountNum"

    if [[ "$AWS_ACCOUNT_ID" == "000000000000" ]]; then
        awsDeployDisabled="y"
    else
        awsDeployDisabled="n"
    fi
}

# adds AWS_DEFAULT_REGION or AWS_SECONDARY_REGION to global namespace
# param1: variable name to set
ask_aws_region () {
    local varName="$1"
    local regions=()
    regions+=("ap-east-1 (Hong Kong)")
    regions+=("ap-northeast-1 (Tokyo)")
    regions+=("ap-northeast-2 (Seoul)")
    regions+=("ap-northeast-3 (Osaka)")
    regions+=("ap-south-1 (Mumbai)")
    regions+=("ap-south-2 (Hyderabad)")
    regions+=("ap-southeast-1 (Singapore)")
    regions+=("ap-southeast-2 (Sydney)")
    regions+=("ap-southeast-3 (Jakarta)")
    regions+=("ap-southeast-4 (Melbourne)")
    regions+=("eu-central-1 (Frankfurt)")
    regions+=("eu-central-2 (Zurich)")
    regions+=("eu-north-1 (Stockholm)")
    regions+=("eu-south-1 (Milan)")
    regions+=("eu-south-2 (Spain)")
    regions+=("eu-west-1 (Ireland)")
    regions+=("eu-west-2 (London)")
    regions+=("eu-west-3 (Paris)")
    regions+=("us-east-1 (N. Viginia)")
    regions+=("us-east-2 (Ohio)")
    regions+=("us-west-1 (N. Califonia)")
    regions+=("us-west-2 (Oregon)")

    local regionCodes=()
    local i
    for i in ${!regions[@]}; do
        regionCodes+=("${regions[$i]%[[:space:]](*}") # trim region description off the end
    done

    local joinedRegionNames
    printf -v joinedRegionNames '%s|' "${regions[@]}"

    local joinedRegionCodes
    printf -v joinedRegionCodes '%s|' "${regionCodes[@]}"
    echo ""

    if [[ "$varName" == "AWS_DEFAULT_REGION" ]]; then
        local defaultRegion=$(echo $choiceCacheJson | jq -r '.defaultRegion | select(type == "string")')
        defaultRegion="${defaultRegion:=us-east-1}"
        echo "What is the default AWS region for the application environment?"
        AWS_DEFAULT_REGION=$(select_with_default "$joinedRegionNames" "$joinedRegionCodes" "$defaultRegion")
    else
        local defaultSecondaryRegion=$(echo $choiceCacheJson | jq -r '.defaultSecondaryRegion | select(type == "string")')
        defaultSecondaryRegion="${defaultSecondaryRegion:=us-west-2}"
        echo "What is the secondary AWS region for the application environment?"
        AWS_SECONDARY_REGION=$(select_with_default "$joinedRegionNames" "$joinedRegionCodes" "$defaultSecondaryRegion")
    fi
}

# adds iac to global namespace
ask_which_iac () {
    echo ""
    local defaultIaC=$(echo $choiceCacheJson | jq -r '.defaultIaC | select(type == "string")')
    defaultIaC="${defaultIaC:=terraform}"
    echo "Which Infrastructure as Code technology will your project use?"
    iac=$(select_with_default "Terraform|CDK v2 (TypeScript)|CloudFormation" "terraform|cdk2|cf" "$defaultIaC")

    if [[ "$iac" == "terraform" ]]; then

        if ! command -v terraform --version &> /dev/null
        then
            echo -e "${RED} ERROR: terraform could not be found. Please install terraform, then run this script again.${NC}" >&2
            exit 1
        fi

        local tfVer=$(terraform --version)
        echo ""
        echo "Required Terraform Version: 1.4.2 or greater"
        echo "Your Terraform Version: ${tfVer}"
    fi
}

# adds TF_S3_BACKEND_NAME to global namespace
# Terraform state is backed up to an S3 bucket with a
# DynamoDB table for optimistic locking.
optionally_inform_tf_backend_name () {
    if [[ "$iac" != "terraform" ]]; then
        return 0
    fi

    echo ""
    echo "Terraform state files are backed up to an S3 bucket."
    echo "Each application environment will use a unique bucket"
    echo "that can store multiple state files (1 per root Terraform"
    echo "module). The bucket name used by your envrionment will be"
    echo "\"${APP_NAME}-${ENV_NAME}-tf-back-end\"."
    
    TF_S3_BACKEND_NAME="${APP_NAME}-${ENV_NAME}-tf-back-end"
}

# adds useCodeCommitMirror to global namespace
ask_create_code_commit_mirror () {
    if [[ "$gitRepoProvider" == "codecommit" ]]; then
        useCodeCommitMirror=n
        return 0
    fi

    echo ""
    echo "A push mirror is a downstream repository that mirrors the commits made to the"
    echo "upstream repository. Push mirrors passively receive copies of the commits made"
    echo "to the upstream repository. A CodeCommit push mirror is often useful when you"
    echo "want to use CodePipeline for CICD purposes but your upstream repo is not"
    echo "supported by CodePipeline."
    echo ""
    local defaultUseCodeCommitMirror=$(echo $choiceCacheJson | jq -r '.defaultUseCodeCommitMirror | select(type == "string")')
    defaultUseCodeCommitMirror="${defaultUseCodeCommitMirror:=y}"
    yes_or_no useCodeCommitMirror "Do you want to create a push mirror CodeCommit repository" "$defaultUseCodeCommitMirror"
}

# adds useCicd to global namespace
ask_generate_cicd_pipeline () {
    if [[ "$gitRepoProvider" == "codecommit" ]]; then
        useCicd=n
        return 0
    fi

    echo ""
    local defaultUseCicd=$(echo $choiceCacheJson | jq -r '.defaultUseCicd | select(type == "string")')
    defaultUseCicd="${defaultUseCicd:=y}"
    yes_or_no useCicd "Do you want a CICD pipeline generated for your project" "$defaultUseCicd"
}

# adds cicd to global namespace
ask_which_cicd_tech () {
    if [[ "$useCicd" == "y" ]]; then
        echo ""
        local defaultCicd=$(echo $choiceCacheJson | jq -r '.defaultCicd | select(type == "string")')
        defaultCicd="${defaultCicd:=gitlab}"
        echo "Which CICD technology will your project use?"
        cicd=$(select_with_default "GitLab" "gitlab" "$defaultCicd")
    fi
}

# adds useSonarQube to global namespace
ask_if_use_sonarqube () {
    echo ""
    echo "SonarQube is a static code analysis (SAST) tool that can detect issues in your"
    echo "code related to security and coding best practices. The results of a SonarQube"
    echo "scan will provide valuable evidence for a security review of your project."
    echo ""
    local defaultUseSonarQube=$(echo $choiceCacheJson | jq -r '.defaultUseSonarQube | select(type == "string")')
    defaultUseSonarQube="${defaultUseSonarQube:=y}"
    yes_or_no useSonarQube "Do you want to use SonarQube to scan your project" "$defaultUseSonarQube"
}

# adds genEnvUtils to global namespace
ask_if_generate_environment_utilities () {
    echo ""
    echo "PACE environment utilities make it easy to create multiple"
    echo "application environments, switch between them easily,"
    echo "and sync local environment settings with remote stores."
    echo "The environment utilities can be included or excluded from"
    echo "the customer deliverable at your discretion."
    local defaultGenEnvUtils=$(echo $choiceCacheJson | jq -r '.defaultGenEnvUtils | select(type == "string")')
    defaultGenEnvUtils="${defaultGenEnvUtils:=y}"
    yes_or_no genEnvUtils "Do you want to include the environment utilities in your application" "$defaultGenEnvUtils"
}

# adds deployCodeCommitPushMirror to global namespace
optionally_ask_if_deploy_code_commit_push_mirror () {
    if [[ "$awsDeployDisabled" == "y" ]]; then
	    deployCodeCommitPushMirror="n"
        return 0
    fi

    if [[ "$useCodeCommitMirror" == "y" ]]; then
        echo ""
        if [[ "$iac" == "cf" ]]; then
            echo The CodeCommit push mirror is defined in a CloudFormation stack.
            echo "The stack name will be: ${APP_NAME}-codecommit"
        fi
        local defaultDeployCodeCommitPushMirror=$(echo $choiceCacheJson | jq -r '.defaultDeployCodeCommitPushMirror | select(type == "string")')
        defaultDeployCodeCommitPushMirror="${defaultDeployCodeCommitPushMirror:=y}"
        yes_or_no deployCodeCommitPushMirror "Do you want to deploy the CodeCommit push mirror to AWS" "$defaultDeployCodeCommitPushMirror"
    fi
}

# adds deployRole to global namespace
ask_if_deploy_cicd_iam_role () {
    if [[ "$awsDeployDisabled" == "y" ]]; then
        deployRole="n"
        return 0
    fi

    if [[ "$useCicd" == "y" ]]; then
        echo ""
        echo Your CICD pipeline will need to assume an IAM role.
        if [[ "$iac" == "cf" ]]; then
            echo The role is defined in a CloudFormation stack.
            echo "The stack name will be: ${APP_NAME}-${ENV_NAME}-role"
        fi
        local defaultDeployRole=$(echo $choiceCacheJson | jq -r '.defaultDeployRole | select(type == "string")')
        defaultDeployRole="${defaultDeployRole:=y}"
        yes_or_no deployRole "Do you want to deploy the CICD IAM role to AWS" "$defaultDeployRole"
    fi
}

# adds deployRemoteEnvVars to global namespace
optionally_ask_push_env_vars () {
    if [[ "$awsDeployDisabled" == "y" ]] && [[ "$REMOTE_ENV_VAR_LOC" == "ssm" ]]; then
	    deployRemoteEnvVars="n"
        return 0
    fi 

    if [[ "$REMOTE_ENV_VAR_LOC" != "na" ]]; then
        echo ""
        local defaultDeployRemoteEnvVars=$(echo $choiceCacheJson | jq -r '.defaultDeployRemoteEnvVars | select(type == "string")')
        defaultDeployRemoteEnvVars="${defaultDeployRemoteEnvVars:=y}"
        local storeName="SSM"
        [ "$REMOTE_ENV_VAR_LOC" == "gitlab" ] && storeName="GitLab"
        yes_or_no deployRemoteEnvVars "Do you want to push \"$ENV_NAME\" environment variables to the remote store ($storeName)" "$defaultDeployRemoteEnvVars"
    else
        defaultDeployRemoteEnvVars="n"
    fi
}

# adds SONAR_HOST_URL to global namespace
# param1: default url value
optionally_ask_sonarqube_host_url () {
    if [[ "$useSonarQube" != "y" ]]; then
        return 0
    fi

    echo ""
    local paramDefaultSonarHostUrl="$1"
    local defaultSonarQubeHostUrl=$(echo $choiceCacheJson | jq -r '.defaultSonarQubeHostUrl | select(type == "string")')
    if [[ -z "$defaultSonarQubeHostUrl" ]]; then
        defaultSonarQubeHostUrl="$paramDefaultSonarHostUrl"
    fi
    length_range SONAR_HOST_URL "Enter the SonarQube host URL:" \
    "$defaultSonarQubeHostUrl" "5" "130"
}

# adds SONAR_PROJECT_KEY to global namespace
optionally_ask_sonarqube_project_key () {
    if [[ "$useSonarQube" != "y" ]]; then
        return 0
    fi

    if [[ "$CREATE_APP" == "true" ]]; then
        defaultSonarQubeProjectKey="generate"
    else
        defaultSonarQubeProjectKey="$APP_NAME"
    fi

    echo ""
    if [[ "$CREATE_APP" != "true" ]]; then
        echo "Hint: Generally, you should only have a single SonarQube project per"
        echo "application since it can be used to scan multiple Git branches."
        echo -e "Check ${CYAN}${SONAR_HOST_URL}/dashboard?id=$defaultSonarQubeProjectKey${NC}"
        echo "to see if SonarQube has already been set up for your project."
        echo ""
    fi
    length_range SONAR_PROJECT_KEY "Enter the existing SonarQube project key or \"generate\" to create a new project on the Sonar host ($SONAR_HOST_URL):" \
    "$defaultSonarQubeProjectKey" "1" "80"
}

# adds SONAR_TOKEN to global namespace
optionally_ask_sonarqube_project_token () {
    if [[ "$useSonarQube" != "y" ]] || [[ ! -z "$SONAR_TOKEN" ]]; then
        return 0
    fi

    echo ""
    echo "For security purposes, the text you type next will not be shown in the terminal."
    echo "Enter the SonarQube project token or \"generate\" to create a new token on an existing project:"
    read_secret SONAR_TOKEN
}

# adds REMOTE_ENV_VAR_LOC to global namespace
ask_where_to_store_remote_env_vars () {
    echo ""
    if [[ "$useCicd" == "y" ]]; then
        echo "Your CICD pipeline will need environment variables to be set."
        local whereStore="Where do you want to store remote pipeline variables?"
        local envVarLocNames="AWS SSM Parameter Store|GitLab (requires Maintainer privileges)"
        local envVarLocVals="ssm|gitlab"
        local localDefaultLoc="gitlab"
    else
        echo "You can optionally store your environment variables remotely for reference by your teammates."
        local whereStore="Where do you want to store remote environment variables?"
        if [[ "$gitRepoDomain" == *"codecommit"* ]]; then
            local envVarLocNames="AWS SSM Parameter Store|Do not store"
            local envVarLocVals="ssm|na"
        else
            local envVarLocNames="AWS SSM Parameter Store|GitLab (requires Maintainer privileges)|Do not store"
            local envVarLocVals="ssm|gitlab|na"
        fi
        local localDefaultLoc="na"
    fi

    echo ""
    local defaultRemoteEnvVarLoc=$(echo $choiceCacheJson | jq -r '.defaultRemoteEnvVarLoc | select(type == "string")')
    defaultRemoteEnvVarLoc="${defaultRemoteEnvVarLoc:=$localDefaultLoc}"
    echo "$whereStore"
    REMOTE_ENV_VAR_LOC=$(select_with_default "$envVarLocNames" "$envVarLocVals" "$defaultRemoteEnvVarLoc")
}

# adds deployTfBackend to global namespace
ask_if_deploy_terraform_backend_cf_stack () {
    if [[ "$awsDeployDisabled" == "y" ]]; then
	    deployTfBackend="n"
        return 0
    fi  

    if [[ "$iac" == "terraform" ]]; then
        echo ""
        echo The Terraform backend is configured in a CloudFormation stack.
        echo "The stack name will be \"$TF_S3_BACKEND_NAME\"."
        local defaultDeployTfBackend=$(echo $choiceCacheJson | jq -r '.defaultDeployTfBackend | select(type == "string")')
        defaultDeployTfBackend="${defaultDeployTfBackend:=y}"
        yes_or_no deployTfBackend "Do you want to deploy the Terraform back end stack to AWS" "$defaultDeployTfBackend"
    fi
}

# adds deployCdk2Backend to global namespace
ask_if_deploy_cdk2_bootstrap_cf_stack () {
    if [[ "$awsDeployDisabled" == "y" ]]; then
        deployCdk2Backend="n"
        return 0
    fi

    if [[ "$iac" == "cdk2" ]]; then
        echo ""
        echo "The AWS CDK needs to be "bootstrapped" once per AWS account."
        local defaultDeployCdk2Backend=$(echo $choiceCacheJson | jq -r '.defaultDeployCdk2Backend | select(type == "string")')
        defaultDeployCdk2Backend="${defaultDeployCdk2Backend:=y}"
        yes_or_no deployCdk2Backend "Do you want to run \"cdk bootstrap\"" "$defaultDeployCdk2Backend"
    fi
}

# Must be run from project directory, not wizard source code directory
optionally_deploy_code_commit_mirror () {
    if [[ "$deployCodeCommitPushMirror" == "y" ]]; then
        export IS_VALID_CLI_ACCOUNT_ID=y && make deploy-codecommit-push-mirror-stack
    fi
}

# Must be run from project directory, not wizard source code directory
optionally_deploy_cicd_iam_role () {
    if [[ "$deployRole" == "y" ]]; then
        export IS_VALID_CLI_ACCOUNT_ID=y && make deploy-cicd-iam-role-stack
    fi
}

# Must be run from project directory, not wizard source code directory
optionally_deploy_cicd_resources () {
    if [[ "$deployRole" == "y" ]] || [[ "$deployCodeCommitPushMirror" == "y" ]]; then
        export IS_VALID_CLI_ACCOUNT_ID=y && make deploy-cicd
    fi
}

# Must be run from project directory, not wizard source code directory
optionally_deploy_terraform_back_end_cf_stack () {
    if [[ "$deployTfBackend" == "y" ]]; then
        export IS_VALID_CLI_ACCOUNT_ID=y && make deploy-tf-backend-cf-stack
    fi
}

# Must be run from project directory, not wizard source code directory
optionally_deploy_cdk2_bootstrap_cf_stack () {
    if [[ "$deployCdk2Backend" == "y" ]]; then
        export IS_VALID_CLI_ACCOUNT_ID=y && make deploy-cdk2-bootstrap-cf-stack
    fi
}

# Must be run from project directory, not wizard source code directory
optionally_push_env_vars_to_remote () {
    if [[ "$deployRemoteEnvVars" == "y" ]]; then
        make push-env-vars
    fi
}

# Sets Bash nameref variable to the name of the Infrastructure as Code technology
# param1: the nameref variable
get_iac_name () {
    local -n returnIacName=$1
    if [[ "$iac" == "cf" ]]; then
        returnIacName="CloudFormation"
    elif [[ "$iac" == "terraform" ]]; then
        returnIacName="Terraform"
    elif [[ "$iac" == "cdk2" ]]; then
        returnIacName="CDK v2"
    else
        returnIacName="Unknown IaC Provider"
    fi
}