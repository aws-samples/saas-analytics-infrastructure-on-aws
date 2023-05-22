#!/usr/bin/env bash

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RED='\033[0;31m'
NC='\033[0m' # No Color
deployRegion=$1
drRegionDescription=$2
CI_ORIG=$CI
: ${CI_ORIG:=false}

if [[ -z "$deployRegion" ]]; then
    echo -e "${RED} ERROR: The region must be passed as the first argument to this script.${NC}" >&2
    exit 1
fi

pattern="^(primary|secondary)$"
if [[ ! $drRegionDescription =~ $pattern ]]; then
    echo -e "${RED} ERROR: The region description (\"primary\" or \"secondary\") must be passed as the second argument to this script.${NC}" >&2
    exit 1
fi

echo ""
echo "Deploying Customer Dashboard UI to $drRegionDescription"
cd $scriptDir/..
rm -rf iac/roots/dashboard/customer/ui/build
export DYNAMIC_RESOLUTION=y && export AWS_DEFAULT_REGION=$deployRegion && FAIL_ON_LOOKUP_ERROR=y && environment/utility-functions.sh resolve_template_files "backup" "iac/roots/dashboard/customer/ui"
cd iac/roots/dashboard/customer/ui
export CI=false # setting to false to get build to pass

# dont let the .bak file get used by the React build
mv public/index.html.bak ../../index.html.bak

npm install
npm run build

# put the .bak file where it belongs after the React build
mv ../../index.html.bak public/index.html.bak

export CI=$CI_ORIG
cd -
environment/utility-functions.sh restore_template_files "iac/roots/dashboard/customer/ui"
export DYNAMIC_RESOLUTION=n && export AWS_DEFAULT_REGION=$AWS_PRIMARY_REGION && environment/utility-functions.sh exec_tf_for_env dashboard/customer/infra/$drRegionDescription
echo "Finished Deploying Customer Dashboard UI to $drRegionDescription"
echo ""