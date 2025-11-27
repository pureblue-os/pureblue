#!/bin/bash

set -euo pipefail

echo "==> Configuring Pureblue branding in os-release"

# Validate required environment variable
IMAGE_ID=${IMAGE_ID:?required}

# Extract Fedora version from the base image
FEDORA_VERSION=$(rpm -E %fedora)
BUILD_DATE=$(date +%Y%m%d)
SUPPORT_END=$(date -d "+13 months" +%Y-%m)

cat > /usr/lib/os-release <<EOF
NAME="Pureblue"
VERSION="${FEDORA_VERSION} (Bootc)"
RELEASE_TYPE=stable
ID=fedora
ID_LIKE="fedora"
VERSION_ID=${FEDORA_VERSION}
VERSION_CODENAME="Lily"
PLATFORM_ID="platform:f${FEDORA_VERSION}"
PRETTY_NAME="Pureblue ${FEDORA_VERSION}"
ANSI_COLOR="0;38;2;60;110;180"
LOGO=fedora-logo-icon
CPE_NAME="cpe:/o:fedoraproject:fedora:${FEDORA_VERSION}"
DEFAULT_HOSTNAME="pureblue"
HOME_URL="https://github.com/pureblue-os"
DOCUMENTATION_URL="https://github.com/pureblue-os/pureblue"
SUPPORT_URL="https://github.com/pureblue-os/pureblue"
BUG_REPORT_URL="https://github.com/pureblue-os/pureblue/issues"
SUPPORT_END=${SUPPORT_END}
VARIANT="Bootc"
VARIANT_ID=bootc
OSTREE_VERSION='${FEDORA_VERSION}.${BUILD_DATE}'
BUILD_ID="${BUILD_DATE}"
IMAGE_ID="${IMAGE_ID}"
IMAGE_VERSION="${FEDORA_VERSION}.${BUILD_DATE}"
EOF

echo "==> os-release configured successfully"
