#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libkeycloak.sh
. /opt/bitnami/scripts/libos.sh

# Load keycloak environment variables
. /opt/bitnami/scripts/keycloak-env.sh

info "** Starting keycloak **"
# Use only basename
conf_file="$(basename "${KEYCLOAK_CONF_FILE}")"
start_command=("${KEYCLOAK_BIN_DIR}/standalone.sh" "-Djboss.bind.address=${KEYCLOAK_BIND_ADDRESS}" "-Dkeycloak.hostname.fixed.httpPort=${KEYCLOAK_HTTP_PORT}" "-c=${conf_file}")
is_boolean_yes "$KEYCLOAK_ENABLE_TLS" && start_command=("${start_command[@]}" "-Dkeycloak.hostname.fixed.httpsPort=${KEYCLOAK_HTTPS_PORT}")
is_boolean_yes "$KEYCLOAK_ENABLE_STATISTICS" && start_command=("${start_command[@]}" "-Djboss.bind.address.management=0.0.0.0")

if am_i_root; then
    exec gosu "$KEYCLOAK_DAEMON_USER" "${start_command[@]}"
else
    exec "${start_command[@]}"
fi
