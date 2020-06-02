#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libfile.sh
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libphp.sh
. /opt/bitnami/scripts/libphpmyadmin.sh

# Load phpMyAdmin environment
. /opt/bitnami/scripts/phpmyadmin-env.sh

# Load PHP environment, for 'php_conf_set'
# Must be loaded after phpMyAdmin environment file, to avoid MODULE being set to 'php'
. /opt/bitnami/scripts/php-env.sh

# Enable phpMyAdmin configuration file
[[ ! -f "$PHPMYADMIN_CONF_FILE" ]] && cp "${PHPMYADMIN_BASE_DIR}/config.sample.inc.php" "$PHPMYADMIN_CONF_FILE"

# Ensure the phpMyAdmin 'tmp' directory exists and has proper permissions
ensure_dir_exists "$PHPMYADMIN_TMP_DIR"
configure_permissions_ownership "$PHPMYADMIN_BASE_DIR" -d "775" -f "664"

# Configure phpMyAdmin based on build-time defaults
info "Configuring default phpMyAdmin options"
phpmyadmin_conf_set "\$cfg['AllowArbitraryServer']" "$(php_convert_to_boolean "$PHPMYADMIN_DEFAULT_ALLOW_ARBITRARY_SERVER")" yes
phpmyadmin_conf_set "\$cfg['Servers'][\$i]['AllowNoPassword']" "$(php_convert_to_boolean "$DATABASE_DEFAULT_ALLOW_NO_PASSWORD")" yes
# The database port entry is not included in the configuration, so we add it manually right after the host
database_server_host_pattern="^[/\s]*[$]cfg\['Servers'\]\[[$]i\]\['host'\]\s*=.*"
database_server_host_replacement="\$cfg['Servers'][\$i]['host'] = '${DATABASE_DEFAULT_HOST}';\n\$cfg['Servers'][\$i]['port'] = '${DATABASE_DEFAULT_PORT_NUMBER}';"
if ! grep -q "$database_server_host_pattern" "$PHPMYADMIN_CONF_FILE"; then
    error "Could not find pattern '${database_server_host_pattern}' in '$PHPMYADMIN_CONF_FILE'."
    exit 1
fi
replace_in_file "$PHPMYADMIN_CONF_FILE" "$database_server_host_pattern" "$database_server_host_replacement"

# Configure PHP options based on build-time defaults
info "Configuring default PHP options for phpMyAdmin"
php_conf_set upload_max_filesize "$PHP_DEFAULT_UPLOAD_MAX_FILESIZE"
php_conf_set post_max_size "$PHP_DEFAULT_POST_MAX_SIZE"
php_conf_set memory_limit "$PHP_DEFAULT_MEMORY_LIMIT"

# Load additional required libraries
# shellcheck disable=SC1091
. /opt/bitnami/scripts/libwebserver.sh

# Enable build-time web server configuration defaults for phpMyAdmin
info "Creating default web server configuration for phpMyAdmin"
web_server_validate
phpmyadmin_ensure_web_server_app_configuration_exists
