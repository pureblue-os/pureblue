#!/bin/bash
set -euo pipefail

# Remove existing remote if present and add local repo as remote
flatpak remote-delete --system --force pureblue-local 2>/dev/null || true
flatpak remote-add --system --no-gpg-verify pureblue-local file:///usr/share/flatpak/system-repo

# Read app IDs and install them
if [ -f /usr/share/flatpak/system-repo/app-ids.txt ]; then
    for appid in $(cat /usr/share/flatpak/system-repo/app-ids.txt); do
        [ -z "$appid" ] && continue
        echo "Installing $appid from local repo..."
        flatpak install --system -y pureblue-local "$appid" || echo "Failed to install $appid"
    done
fi

# Remove the temporary remote after installation
flatpak remote-delete --system --force pureblue-local 2>/dev/null || true
