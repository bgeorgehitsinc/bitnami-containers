#!/bin/bash

# shellcheck disable=SC2154

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

echo  "$header Locking primary..."
