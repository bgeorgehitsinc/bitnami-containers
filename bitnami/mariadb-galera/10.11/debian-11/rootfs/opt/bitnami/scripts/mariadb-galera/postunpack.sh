#!/bin/bash
# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/libldapclient.sh
. /opt/bitnami/scripts/libmariadbgalera.sh

# Load MariaDB environment variables
. /opt/bitnami/scripts/mariadb-env.sh

# Load LDAP environment variables
eval "$(ldap_env)"

# Configure MariaDB options based on build-time defaults
info "Configuring default MariaDB options"
ensure_dir_exists "$DB_CONF_DIR"
mysql_create_default_config

for dir in "$DB_TMP_DIR" "$DB_LOGS_DIR" "$DB_CONF_DIR" "${DB_CONF_DIR}/bitnami" "$DB_VOLUME_DIR" "$DB_DATA_DIR" "$DB_GALERA_BOOTSTRAP_DIR"; do
    ensure_dir_exists "$dir"
    chmod -R g+rwX "$dir"
done

# LDAP permissions
ldap_configure_permissions
ldap_create_pam_config "mariadb"

# Fix to avoid issues detecting plugins in mysql_install_db
ln -sf "$DB_BASE_DIR/plugin" "$DB_BASE_DIR/lib/plugin"

# Redirect all logging to stdout
ln -sf /dev/stdout "$DB_LOGS_DIR/mysqld.log"
