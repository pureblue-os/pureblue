#!/bin/bash

set -euo pipefail

echo "==> Configuring ostree-related fields in os-release"

OS_RELEASE_FILE="/usr/lib/os-release"

# Validate required environment variables
IMAGE_NAME=${IMAGE_NAME:?required}
IMAGE_VERSION=${IMAGE_VERSION:?required}

# Extract Fedora version from the base image
FEDORA_VERSION=$(rpm -E %fedora)
BUILD_DATE=$(date +%Y%m%d)

# Helper function to update or add a key in os-release
set_os_release_value() {
    local key="$1"
    local value="$2"
    
    if grep -q "^${key}=" "$OS_RELEASE_FILE"; then
        # Key exists, update it
        sed -i "s|^${key}=.*|${key}=${value}|" "$OS_RELEASE_FILE"
    else
        # Key doesn't exist, append it
        echo "${key}=${value}" >> "$OS_RELEASE_FILE"
    fi
}

# Only update ostree-related values
set_os_release_value "OSTREE_VERSION" "'${FEDORA_VERSION}.${BUILD_DATE}'"
set_os_release_value "BUILD_ID" "\"${BUILD_DATE}\""
set_os_release_value "IMAGE_ID" "\"${IMAGE_NAME}\""
set_os_release_value "IMAGE_VERSION" "\"${IMAGE_VERSION}\""

echo "==> os-release ostree fields configured successfully"
