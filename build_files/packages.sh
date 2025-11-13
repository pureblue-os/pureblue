#!/bin/bash

set -ouex pipefail

echo "==> Customizing Pureblue"

# Remove unwanted Bluefin packages here if needed
# dnf5 remove -y <package>

# Install your custom packages here
dnf5 install -y tmux waydroid

# Enable system services
systemctl enable podman.socket

echo "==> Pureblue customization complete"
