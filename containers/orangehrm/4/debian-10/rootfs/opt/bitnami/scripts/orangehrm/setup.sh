#!/bin/bash

# shellcheck disable=SC1090,SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load OrangeHRM environment
. /opt/bitnami/scripts/orangehrm-env.sh

# Load MySQL Client environment for 'mysql_remote_execute' (after 'orangehrm-env.sh' so that MODULE is not set to a wrong value)
if [[ -f /opt/bitnami/scripts/mysql-client-env.sh ]]; then
    . /opt/bitnami/scripts/mysql-client-env.sh
elif [[ -f /opt/bitnami/scripts/mysql-env.sh ]]; then
    . /opt/bitnami/scripts/mysql-env.sh
elif [[ -f /opt/bitnami/scripts/mariadb-env.sh ]]; then
    . /opt/bitnami/scripts/mariadb-env.sh
fi

# Load libraries
. /opt/bitnami/scripts/liborangehrm.sh
. /opt/bitnami/scripts/libwebserver.sh

# Load web server environment and functions (after OrangeHRM environment file so MODULE is not set to a wrong value)
. "/opt/bitnami/scripts/$(web_server_type)-env.sh"

# Ensure OrangeHRM environment variables are valid
orangehrm_validate

# Update web server configuration with runtime environment (needs to happen before the initialization)
web_server_update_app_configuration "orangehrm"

# Ensure OrangeHRM is initialized
orangehrm_initialize
