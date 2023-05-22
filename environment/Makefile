SHELL := /usr/bin/env bash -euo pipefail -c
IGNORE := $(shell bash -c "./utility-functions.sh generate_make_env \"$(MAKECMDGOALS)\"")
include make-env

# List all Make targets in alphabetical order
.PHONY: list
list:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# Wizard to create a new or update an existing application environment
create-environment:
	@./create-app-environment.sh

# Simple create-environment shortcut
ce: create-environment

# Wizard to delete an application environment
delete-environment:
	@./delete-app-environment.sh

# Simple delete-environment shortcut
de: delete-environment

# Presents choice of which local environment to set as the current one
switch-current-environment:
	@./utility-functions.sh switch_local_environment

# Simple switch-current-environment shortcut
sce: switch-current-environment

# Print the current local environment
get-current-environment: 
	@./utility-functions.sh get_current_env

# Simple get-current-environment shortcut
gce: get-current-environment

# Print the current local environments
list-local-environments: 
	@./utility-functions.sh get_local_environment_names

# Simple list-local-environments shortcut
lle: list-local-environments

# Print the current remote environments
list-remote-environments: 
	@./utility-functions.sh get_remote_environment_names

# Simple list-remote-environments shortcut
lre: list-remote-environments

# Resolve placeholders in a file and print the result to the console
# usage: make print-resolved-template-file f=<filePath>
print-resolved-template-file:
	@echo ""
	@echo "Note: set \"DYNAMIC_RESOLUTION\" environment variable to \"y\" to enable dynamic resolution"
	@echo ""
	@./utility-functions.sh print_resolved_placeholders "$(f)"

# Simple print-resolved-template-file shortcut
prt:
	@echo ""
	@echo "Note: set \"DYNAMIC_RESOLUTION\" environment variable to \"y\" to enable dynamic resolution"
	@echo ""
	@./utility-functions.sh print_resolved_placeholders "$(f)"

# Prints the names of all application files that contain environment placeholders.
# Takes an optional "d" parameter if you want to specifiy the starting directory
# in which to search for files that contain placeholders
# usage: 
#   make list-template-files
#   OR
#   make list-template-files d=<pathToDirectory>
list-template-files:
	@./utility-functions.sh get_template_files "$(d)"

# Simple list-template-files shortcut
ltf: 
	@$(MAKE) list-template-files d="$(d)"

# Validates all application templates to ensure that all placeholders
# in all templates can be successfully resolved
validate-template-files:
	@./utility-functions.sh resolve_template_files "dryRun"

# Simple validate-template-files shortcut
vtf: validate-template-files

# Resolves placeholders in all application template files and
# overwrites the files with the resolved content
# WARNING - will leave template files in a changed state
# Takes an optional "d" parameter if you want to specifiy the starting directory
# in which to search for files that contain placeholders
# usage: 
#   make resolve-template-files
#   OR
#   make resolve-template-files d=<pathToDirectory>
resolve-template-files:
	@./utility-functions.sh resolve_template_files "" "$(d)"

# Simple resolve-template-files shortcut
rtf: $(MAKE) resolve-template-files

# Resolves placeholders in all application template files and
# overwrites the files with the resolved content
# A backup of each template is taken before the resolution process
# to allow for undoing the resolve step later
# WARNING - will leave template files in a changed state
# Takes an optional "d" parameter if you want to specifiy the starting directory
# in which to search for files that contain placeholders
# usage: 
#   make backup-resolve-template-files
#   OR
#   make backup-resolve-template-files d=<pathToDirectory>
backup-resolve-template-files:
	@./utility-functions.sh resolve_template_files "backup" "$(d)"

# Simple backup-resolve-template-files shortcut
brtf: $(MAKE) backup-resolve-template-files

# Restores template file backups. This serves as an "undo" for the
# files that were changed by "resolve-template-files"
# Takes an optional "d" parameter if you want to specifiy the starting directory
# in which to search for files that contain placeholders
# usage: 
#   make restore-backup-files
#   OR
#   make restore-backup-files d=<pathToDirectory>
restore-backup-files:
	@./utility-functions.sh restore_template_files "$(d)"

# Simple restore-backup-files shortcut
rbf: 
	$(MAKE) restore-backup-files



# Presents choice of remote environments to import and set as the current one
pull-env-vars:
	@./utility-functions.sh pull_env_vars

# Save off local environment variable settings to a remote store e.g. SSM or GitLab.
# This is useful to make it so that your team members or a CICD pipeline can reference
# environment variable values
push-env-vars:
	@./utility-functions.sh push_env_vars

# Prints a table of CloudTrail logs for IAM permission denied events
# over a date range. Useful for debugging IAM role permissions errors.
list-auth-errors:
	@./utility-functions.sh print_auth_errors

# Simple list-auth-errors shortcut
lae: list-auth-errors

# Execute a utility-function on the current environment
# If you do not supply the "f" argument, the utility function names will be printed out
# usage: make util f=<functionName>
util:
	@echo "Current environment is \"$(ENV_NAME)\""
	./utility-functions.sh "$(f)"





# Deploys the Terraform back end CloudFormation stack
deploy-tf-backend-cf-stack:
	@./utility-functions.sh deploy_tf_backend_cf_stack "$(AWS_PRIMARY_REGION)"
	@./utility-functions.sh deploy_tf_backend_cf_stack "$(AWS_SECONDARY_REGION)" "parameters-secondary.json"
	@./utility-functions.sh deploy_tf_backend_cf_stack "$(AWS_PRIMARY_REGION)" "parameters-crr.json"

# Destroys the Terraform back end CloudFormation stack and deletes Terraform
# state files
destroy-tf-backend-cf-stack:
	@../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-tf-back-end-$(AWS_ACCOUNT_ID)-$(AWS_PRIMARY_REGION)"
	@./utility-functions.sh destroy_tf_backend_cf_stack "$(AWS_PRIMARY_REGION)"
	@../build-script/empty-s3.sh empty_s3_bucket_by_name "$(APP_NAME)-$(ENV_NAME)-tf-back-end-$(AWS_ACCOUNT_ID)-$(AWS_SECONDARY_REGION)"
	@./utility-functions.sh destroy_tf_backend_cf_stack "$(AWS_SECONDARY_REGION)"

request-eip-quota-increase:
	bash ../build-script/aws-quota-increase/request-eip-quota-increase.sh "15" "$(AWS_PRIMARY_REGION)"
	bash ../build-script/aws-quota-increase/request-eip-quota-increase.sh "15" "$(AWS_SECONDARY_REGION)"

create-pandas-zip:
	bash ../build-script/create-pandas.sh

deploy-initialization:
	./utility-functions.sh exec_tf_for_env initialization

destroy-initialization:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env initialization

deploy-cognito-configuration:
	./utility-functions.sh exec_command_for_env "../build-script" "bash deploy-cognito.sh"

deploy-network:
	./utility-functions.sh exec_tf_for_env network

destroy-network:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env network

deploy-customer1:
	./utility-functions.sh exec_tf_for_env customers/customer1

destroy-customer1:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env customers/customer1

deploy-customer2:
	./utility-functions.sh exec_tf_for_env customers/customer2

destroy-customer2:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env customers/customer2

deploy-analytics1:
	./utility-functions.sh exec_tf_for_env analytics/analytics1

destroy-analytics1:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env analytics/analytics1

deploy-customer1-input:
	@echo "Deploying Customer1 Input File to Customer1 Input Bucket"
	(aws s3api put-object --bucket $(APP_NAME)-$(ENV_NAME)-customer-input-000001-primary --key input-2022-09-23-000001-000001.csv --body ../input-2022-09-23-000001-000001.csv  --region $(AWS_PRIMARY_REGION);)
	@echo "Finished Deploying Customer1 Input File to Customer1 Input Bucket"

deploy-customer2-input:
	@echo "Deploying Customer2 Input File to Customer2 Input Bucket"
	(aws s3api put-object --bucket $(APP_NAME)-$(ENV_NAME)-customer-input-000002-primary --key input-2022-09-23-000002-000001.csv --body ../input-2022-09-23-000002-000001.csv  --region $(AWS_PRIMARY_REGION);)
	@echo "Finished Deploying Customer2 Input File to Customer2 Input Bucket"

deploy-dashboard-api:
	./utility-functions.sh exec_tf_for_env dashboard/api

destroy-dashboard-api:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env dashboard/api

deploy-admin-dashboard-ui-primary:
	bash ../build-script/deploy-admin-dashboard-ui-regional.sh "$(AWS_PRIMARY_REGION)" "primary"

destroy-admin-dashboard-ui-primary:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env dashboard/admin/infra/primary

deploy-admin-dashboard-ui-secondary:
	bash ../build-script/deploy-admin-dashboard-ui-regional.sh "$(AWS_SECONDARY_REGION)" "secondary"

destroy-admin-dashboard-ui-secondary:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env dashboard/admin/infra/secondary

deploy-customer-dashboard-ui-primary:
	bash ../build-script/deploy-customer-dashboard-ui-regional.sh "$(AWS_PRIMARY_REGION)" "primary"

destroy-customer-dashboard-ui-primary:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env dashboard/customer/infra/primary

deploy-customer-dashboard-ui-secondary:
	bash ../build-script/deploy-customer-dashboard-ui-regional.sh "$(AWS_SECONDARY_REGION)" "secondary"

destroy-customer-dashboard-ui-secondary:
	export TF_MODE=destroy && ./utility-functions.sh exec_tf_for_env dashboard/customer/infra/secondary

empty-app-env-s3-buckets-interactive:
	bash ../build-script/empty-all-s3-for-app-env.sh "interactive"

empty-app-env-s3-buckets-headless:
	bash ../build-script/empty-all-s3-for-app-env.sh "headless"

verify-output-files:
	@echo "Reading Output Files"
	@echo "File1: "
	(aws s3 ls s3://$(APP_NAME)-$(ENV_NAME)-customer-output-000001-primary/output-2022-09-23-000001-000001.csv)
	@echo "File2: "
	(aws s3 ls s3://$(APP_NAME)-$(ENV_NAME)-customer-output-000002-primary/output-2022-09-23-000002-000001.csv)
	@echo "Finished Reading Output Files"

delete-output-files:
	@echo "Deleting Output Files"
	@echo "File1: "
	(aws s3 rm s3://$(APP_NAME)-$(ENV_NAME)-customer-output-000001-primary/output-2022-09-23-000001-000001.csv)
	@echo "File2: "
	(aws s3 rm s3://$(APP_NAME)-$(ENV_NAME)-customer-output-000002-primary/output-2022-09-23-000002-000001.csv)
	@echo "Finished Deleting Output Files"

deploy-all: create-pandas-zip deploy-initialization deploy-cognito-configuration deploy-network deploy-customer1 deploy-customer2 deploy-analytics1 deploy-customer1-input deploy-customer2-input deploy-dashboard-api deploy-admin-dashboard-ui-primary deploy-admin-dashboard-ui-secondary deploy-customer-dashboard-ui-primary deploy-customer-dashboard-ui-secondary
destroy-all: empty-app-env-s3-buckets-headless destroy-customer-dashboard-ui-secondary destroy-customer-dashboard-ui-primary destroy-admin-dashboard-ui-secondary destroy-admin-dashboard-ui-primary destroy-dashboard-api destroy-analytics1 destroy-customer2 destroy-customer1 destroy-network destroy-initialization
