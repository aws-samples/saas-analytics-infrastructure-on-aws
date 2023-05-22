#!/usr/bin/env bash

# This script is a wizard that will create a new local environment
# for you by walking you through a guided series of questions.
# It can also be run in "headless" mode by supplying a JSON file
# with environment values as the first argument to the script.

# Get original values for stdin and stderr for later reference
exec 21>&1
exec 22>&2

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $scriptDir/utility-functions.sh "source" 1> /dev/null
validate_bash_version
source $scriptDir/create-app-env-questions.sh 1> /dev/null

if [[ -f "$scriptDir/dynamic-lookups.sh" ]]; then
    source $scriptDir/dynamic-lookups.sh 1> /dev/null
else
    declare -A LOOKUPS=()
fi

# Write user choices to JSON cache file used by subsequent wizard run default values
write_choices_to_cache_file () {

    # Reinstate original stdout and stderr that may have been redirected
    exec 1>&21
    exec 2>&22

    # Enable echo. This may have been disabled when reading secret values
    stty echo

    populate_create_app_env_choice_cache_array
    printf -v joined '%s,' "${choiceEnvCacheArray[@]}"
    echo -n "${joined%,}" | jq -R -s 'split(",") | map(split("=")) | map({(.[0]): .[1]}) | add' > $choiceCacheFilePath
}

# Add an event handler for when the script exits
trap write_choices_to_cache_file EXIT

choiceCacheFilePath=$scriptDir/.choice-cache.json
choiceCacheJson=""
choiceEnvCacheArray=()

# Populate an array of required environment variable parameters
get_env_var_names envVarNames || exit 1

# Exports (as environment variables) all values defined in the supplied .json
# file so that this wizard can run in headless mode.
# param1: a working path (absolute or relative) to the JSON file 
#         containing wizard answers
export_wizard_answers () {
    
    if ! command -v jq --version &> /dev/null
    then
        echo -e "${RED} ERROR: jq could not be found. Please install jq, then run this script again.${NC}" >&2
        exit 1
    fi

    if [[ ! -f "$1" ]]; then
        echo -e "${RED} ERROR: Failed to get headless mode values from JSON file.${NC}" >&2
        echo "File \"$1\" does not exist." >&2
        exit 1
    fi

    eval "export $(cat "$1" \
    | jq -r 'to_entries | map("\(.key)=\(.value)") | @sh')"
}

init_interactive_mode () {

    CREATED_BY="blank"

    # Note - the following value was generated at project creation time.
    # Edit with caution.
    initialChoiceVals=""

    # --------------------------------------------------------------
    if [[ -f $choiceCacheFilePath ]]; then
        yes_or_no useChoiceCache "Would you like to load default selections from previous run" "y"
        if [[ $useChoiceCache =~ ^[Yy]$ ]]; then
            choiceCacheJson=$(<$choiceCacheFilePath)
        fi
    elif [[ ! -z "$initialChoiceVals" ]]; then
        # Create a local choice cache file based on initial project creation values
        echo -n "${initialChoiceVals%,}" | jq -R -s 'split(",") | map(split("=")) | map({(.[0]): .[1]}) | add' > $choiceCacheFilePath

        useChoiceCache="y"
        choiceCacheJson=$(<$choiceCacheFilePath)
        
    fi
}

detect_settings () {
    set_git_env_vars_from_remote_origin

    if [[ " ${envVarNames[*]} " =~ " TF_S3_BACKEND_NAME " ]]; then
        iac="terraform"
    fi

    cdkJsonFile=$(find $projectIacDir -type f -name 'cdk.json')
    if [[ ! -z "$cdkJsonFile" ]]; then
        iac="cdk2"
    fi

    if [[ " ${envVarNames[*]} " =~ " AWS_CREDS_TARGET_ROLE " ]]; then
        AWS_CREDS_TARGET_ROLE="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${APP_NAME}-${ENV_NAME}-cicd-role"
    fi

    if [[ -d "$scriptDir/../cicd" ]]; then
        useCicd="y"
    else 
        useCicd="n"
    fi

    if [[ -f "$scriptDir/../.gitlab-ci.yml" ]]; then
        cicd="gitlab"
    fi

    if [[ -f "$scriptDir/../sonar-project.properties" ]]; then
        useSonarQube="y"
    else 
        useSonarQube="n"
    fi
}

run_interactive_mode () {
    
    ask_aws_account_number
    set_aws_cli_profile
    ask_aws_region "AWS_DEFAULT_REGION"
    if [[ "$awsDeployDisabled" == "n" ]]; then
        validate_aws_cli_account
    fi

    if [[ " ${envVarNames[*]} " =~ " AWS_SECONDARY_REGION " ]]; then
        AWS_PRIMARY_REGION="$AWS_DEFAULT_REGION"
        ask_aws_region "AWS_SECONDARY_REGION"
    fi

    ask_app_name
    ask_environment_name "ignoreDefault"

    # Even though this value is set by detect_settings, we update it here with the latest user entries
    if [[ " ${envVarNames[*]} " =~ " AWS_CREDS_TARGET_ROLE " ]]; then
        AWS_CREDS_TARGET_ROLE="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${APP_NAME}-${ENV_NAME}-cicd-role"
    fi

    ask_enable_once_per_account_resources

    if [[ "$iac" == "terraform" ]]; then
        optionally_inform_tf_backend_name
    fi

    if [[ "$useCicd" == "y" ]]; then
        ask_if_use_new_environment_with_cicd_pipeline
        useCicd=$useEnvWithCicd
    fi

    ask_where_to_store_remote_env_vars
    optionally_ask_sonarqube_host_url ""
    optionally_ask_sonarqube_project_key
    if [[ "$SONAR_PROJECT_KEY" == "generate" ]]; then
        create_sonarqube_project
    fi
    optionally_ask_sonarqube_project_token
    if [[ "$SONAR_TOKEN" == "generate" ]]; then
        create_sonarqube_project_token
    fi
    optionally_ask_created_by
    ask_if_deploy_cicd_iam_role
    optionally_ask_push_env_vars
    ask_if_deploy_terraform_backend_cf_stack
    ask_if_deploy_cdk2_bootstrap_cf_stack

    # Check for custom environment variables added to app-env-var-names.txt
    # that are application-specific
    frameworkVars=$(get_framework_env_var_names)
    for varIndex in ${!envVarNames[@]}; do
        varName=${envVarNames[$varIndex]}

        if [[ ! " $frameworkVars " =~ " ${varName} " ]] && [[ -z "${LOOKUPS[$varName]}" ]]; then

            # do not prompt for Git repo entries
            if [[ "$varName" == "git"* ]]; then continue; fi

            echo ""
            length_range customVal "Enter a value for $varName:" \
            "" "0" "100" "allowWhitespace"
            customVal="${customVal:=blank}"
            dynamicVarSet="${varName}=\"$customVal\""
            eval $dynamicVarSet
        fi
    done
}

validate_headless_mode_input () {
    local awsAcctPattern="^[0-9]{12}$"
    if [[ ! $AWS_ACCOUNT_ID =~ $awsAcctPattern ]]; then
        echo -e "${RED} ERROR: invalid \"AWS_ACCOUNT_ID\" value: \"$AWS_ACCOUNT_ID\". Must be a 12-digit number.${NC}" >&2
        exit 1
    fi

    if [[ "$REMOTE_ENV_VAR_LOC" != "ssm" ]] && [[ "$REMOTE_ENV_VAR_LOC" != "gitlab" ]] && [[ "$REMOTE_ENV_VAR_LOC" != "na" ]]; then
        echo -e "${RED} ERROR: invalid \"REMOTE_ENV_VAR_LOC\" value: \"$REMOTE_ENV_VAR_LOC\". Must be \"ssm\" or \"gitlab\" or \"na\".${NC}" >&2
        exit 1
    fi

    if [[ "$REMOTE_ENV_VAR_LOC" == "na" ]] && [[ "$deployRole" == "y" ]]; then
        echo -e "${RED} ERROR: invalid \"deployRole\" value: \"$deployRole\". Must be \"n\" if REMOTE_ENV_VAR_LOC is \"na\".${NC}" >&2
        exit 1
    fi

    [[ ! "$APP_NAME" =~ ^[^[:space:]]{1,10}$ ]] && \
    echo -e "${RED} ERROR: \"APP_NAME\" value is invalid: \"$APP_NAME\".${NC}" >&2 && \
    echo "Must not include whitespace and length (${#APP_NAME}) must be between 1 and 10." >&2 && \
    exit 1
    
    [[ ! "$ENV_NAME" =~ ^[^[:space:]]{1,6}$ ]] && \
    echo -e "${RED} ERROR: \"ENV_NAME\" value is invalid: \"$ENV_NAME\".${NC}" >&2 && \
    echo "Must not include whitespace and length (${#ENV_NAME}) must be between 1 and 6." >&2 && \
    exit 1

    [[ ! "$AWS_DEFAULT_REGION" =~ ^[^[:space:]]{5,30}$ ]] && \
    echo -e "${RED} ERROR: \"AWS_DEFAULT_REGION\" value is invalid: \"$AWS_DEFAULT_REGION\".${NC}" >&2 && \
    echo "Must not include whitespace and length (${#AWS_DEFAULT_REGION}) must be between 5 and 30." >&2 && \
    exit 1

    validate_true_or_false "ENABLE_ONCE_PER_ACCOUNT_RESOURCES" "$ENABLE_ONCE_PER_ACCOUNT_RESOURCES"
    validate_yes_or_no "useCicd" "$useCicd"
    validate_yes_or_no "useEnvWithCicd" "$useEnvWithCicd"
    validate_yes_or_no "deployRole" "$deployRole"

    if [[ "$deployRemoteEnvVars" == "y" ]] && [[ "$cicd" == "gitlab" ]]; then
        if [[ -z "$gltoken" ]]; then
            echo -e "${RED} ERROR: no value found for GitLab personal access token.${NC}" >&2
            echo "You must set \"gltoken\" as an environment variable with the token value" >&2
            echo "or set \"deployRemoteEnvVars\" to \"n\"." >&2
            exit 1
        fi
    fi
}

set_headless_mode_default_values () {
    if [[ "$REMOTE_ENV_VAR_LOC" == "na" ]]; then
        useEnvWithCicd="n"
    else
        useEnvWithCicd="y"
    fi

    if [[ -z "$deployRole" ]]; then
        deployRole="$useEnvWithCicd"
    fi

    deployRemoteEnvVars="$useEnvWithCicd"

    if [[ "$iac" == "terraform" ]]; then
        deployTfBackend="y"
    else
       deployTfBackend="n" 
    fi
    
    if [[ "$iac" == "cdk2" ]]; then
        deployCdk2Backend="y"
    else
        deployCdk2Backend="n"
    fi
}

echo ""
echo "Welcome to the Create/Update App Environment Wizard!"
echo ""

if [[ ! -z "$1" ]]; then
    export HEADLESS="y"
    export_wizard_answers "$1"
    detect_settings
    set_headless_mode_default_values
    validate_headless_mode_input

    echo "Running in headless mode."

    if [[ "$useCicd" == "y" ]]; then
        echo "Default settings can be overriden by setting environment variables in the shell before running this wizard."
        echo "Settings:"
        echo "deployRole=$deployRole"
        echo "Explanation: deployRole can be set to \"y\" if you want the CICD IAM role to be deployed to AWS"
    fi
    
    echo ""
    
else
    init_interactive_mode
    detect_settings
    run_interactive_mode
fi

# --------------------------------------------------------------

# Write out new environment json file
envVarValueJsonFile=".environment-$ENV_NAME.json"
app_env_vars_to_json > $scriptDir/$envVarValueJsonFile
echo $ENV_NAME > $scriptDir/.current-environment

if [[ "$iac" != "cf" ]]; then
    optionally_deploy_cicd_resources
else
    optionally_deploy_cicd_iam_role
fi

optionally_push_env_vars_to_remote
optionally_deploy_terraform_back_end_cf_stack
optionally_deploy_cdk2_bootstrap_cf_stack

echo ""
echo -e "${GREEN}Congratulations! Your \"$ENV_NAME\" application environment has been created.${NC}"
echo ""
echo "You can open the \"environment/$envVarValueJsonFile\" file to see what settings were generated."
echo "This file can be modified by you as necessary or you can always rerun this wizard."
echo ""