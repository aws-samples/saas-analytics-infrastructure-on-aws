## Deploying the Solution

**Prerequisites**

* [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) - 1.4.2 or higher
* [node.js](https://nodejs.org/en/) - 18.12 or higher
* [Git CLI](https://git-scm.com/downloads)
* [make](https://www.gnu.org/software/make/)
* [jq](https://stedolan.github.io/jq/)
* Bash shell with version 5.0 or greater.

This project includes scripts that can customize it with environment-specific
settings and deploy it to 1 or more AWS accounts/regions. The scripts require some
set up before they can be run successfully. At a high level, the scripts support
the resolution of placeholders in the source code files with values pulled from 
environment variables. This allows for the appliction to be easily customized and 
deployed to multiple AWS accounts or to the same account multiple times. Placeholders
are easily recognizable in the code since they are surrounded with 3 pound signs
(#).

Once all of the script prerequisites have been met, you can set up a new application
environment configuration by running the Create New Application Environment Wizard
using the below commands. Once you have set up an environment, you can utilize
the scripts to deploy the infrastructure. The scripts take care of resolving all of
the placeholder variables automatically, using the values from the environment 
configurations.

```sh
cd environment
make ce
```

Note - you can run the above steps multiple times to create multiple environment
configurations. You can set which environment configuration will be used for deployment
like so:

```sh
cd environment
make sce
```

After an application environment is configured, you can use the targets
from `environment/Makefile` in order to perform deployments and other tasks.

Before the application can be deployed to a new AWS account, it requires an
increase to the standard maximum number of elastic IP addresses allowed, which is
currently 5 per region. To request an increase to this limit, execute the
following:

```sh
cd environment
make request-eip-quota-increase
```

Once you have increased the elastic IP quota, you can deploy the application
by executing the targets from `environment/Makefile` in the 
following order:

  1. create-pandas-zip
  2. deploy-initialization
  3. deploy-cognito-configuration
  4. deploy-network
  5. deploy-customer1 
  6. deploy-customer2
  7. deploy-analytics1
  8. deploy-customer1-input
  9. deploy-customer2-input
  10. deploy-dashboard-api
  11. deploy-admin-dashboard-ui-primary
  12. deploy-admin-dashboard-ui-secondary
  13. deploy-customer-dashboard-ui-primary
  14. deploy-customer-dashboard-ui-secondary

Note: the `deploy-analytics1` target may fail the first time due to a race
condition. Simply run it a second time to fix the issue.

### SFTP Servers

You can find the name of the SFTP endpoint that SaaS users will connect to by 
logging in to the AWS Web Console and searching for the "AWS Transfer Family" 
service. Navigate to the service page, then select the "Servers" link on the 
left side menu. Click on the server to see its details. The endpoint name to 
supply to SaaS users is listed in the server details. Each region has a 
separate endpoint.

### Steps to configure SFTP access for customers

Open the `iac/roots/customers/<CUSTOMER_NAME>/terraform.tfvars` file.

Each SaaS consumer can have multiple users with SFTP access to the S3 buckets that are specific
to that customer. You can set up a new user for the consumer by adding an object to the
`SFTP_USERS` list.

The user should provide the username and the SSH public key that they want to be set up.
As a convenience, the user's SFTP home directory can be set to either the consumer's file input 
S3 bucket or the consumer's file output S3 bucket. For the former, set the `home_directory_type` 
to "input" and for the latter, set the `home_directory_type` to "output".

 The format of the SSH public key is `ssh-rsa <string>`. For instructions on how to generate 
 an SSH key pair, see 
 [Generate SSH keys](https://docs.aws.amazon.com/transfer/latest/userguide/key-management.html#sshkeygen).

 The SSH public key for the user should be stored in a file named
 `iac/roots/customers/<CUSTOMER_NAME>/sftp-user-public-keys/<USER_NAME>.pub`

 If the SSH public key is set for the first time or changed later, the `make` command that 
 deploys infrastructure for that customer must be rerun. For example, if the
 `iac/roots/customers/customer1/sftp-user-public-keys/customer1.pub` file is updated, you must run `make deploy-customer1` to update the 
 configurations on AWS for customer1.

 Note: once users have logged in to an SFTP session, they can get to the S3 input bucket 
 folder or the S3 output bucket folder using the follwing syntax:
 `cd /<CUSTOMER_S3_BUCKET_NAME>`

### Logging In To The Admin Web Portal

The URL for the Admin Web Portal is stored in the AWS SSM Parameter Store. After the solution
has been deployed, you can get the URL from the store by looking for a key named like so:

`/<APP_NAME>/<ENV_NAME>/admin/cloudfront-domain-name`

Note that you must replace the placeholders above based on the application name and environment
names you have chosen during deployment.

The login password for the admin is also stored in the AWS SSM Parameter store using the following
key format:

`/<APP_NAME>/<ENV_NAME>/admin-password`

The username for the admin is an environment-specific setting that you configure when you deploy the
solution. The name of the setting is `ADMIN_IDP_EMAIL`.

### Logging In To The Customer Web Portal

The URL for the Customer Web Portal is stored in the AWS SSM Parameter Store. After the solution
has been deployed, you can get the URL from the store by looking for a key named like so:

`/<APP_NAME>/<ENV_NAME>/customer/cloudfront-domain-name`

Note that you must replace the placeholders above based on the application name and environment
names you have chosen during deployment.

The login passwords for the default initial customers are also stored in the AWS SSM Parameter 
store using the following key formats:

`/<APP_NAME>/<ENV_NAME>/customer1-password`
`/<APP_NAME>/<ENV_NAME>/customer2-password`

When customers update their passwords, the SSM Parameter Store will not be updated.
It is simply populated as an initial convenience for demonstration purposes only
for the default initial customers.

The usernames for customers are an environment-specific setting that you configure when you deploy the
solution. The name of the settings are `CUSTOMER1_IDP_EMAIL` and `CUSTOMER2_IDP_EMAIL`.