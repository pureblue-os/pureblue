#!/bin/bash

set -ouex pipefail

echo "==> Installing system flatpaks"

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

# Install system flatpaks here
# Example:
# flatpak install --system -y flathub org.mozilla.firefox
# flatpak install --system -y flathub com.spotify.Client

echo "==> System flatpaks installation complete"
