#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/libelasticsearch.sh

# Load Elasticsearch environment variables
. /opt/bitnami/scripts/elasticsearch-env.sh

elasticsearch_healthcheck
