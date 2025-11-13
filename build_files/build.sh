#!/bin/bash

set -ouex pipefail

echo "==> Building base variant"

bash /ctx/cleanup.sh
bash /ctx/extensions.sh
bash /ctx/packages.sh

# Install pureblue-update script
install -Dm755 /ctx/bin/pureblue-update /usr/bin/pureblue-update

echo "==> Base variant build complete"
