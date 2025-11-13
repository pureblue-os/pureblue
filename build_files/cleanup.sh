#!/bin/bash

set -ouex pipefail

echo "==> Removing all system GNOME extensions"

# Remove all system extensions - we'll pick and install what we want later
rm -rf /usr/share/gnome-shell/extensions/*

echo "==> All system GNOME extensions removed"

echo "==> Removing unwanted packages"

# Remove Input Remapper and Tweaks
# dnf5 remove -y input-remapper gnome-tweaks

echo "==> Unwanted packages removed"
