#!/bin/bash
set -euo pipefail

# Add local repo as remote
flatpak remote-add --system --no-gpg-verify pureblue-local file:///usr/share/flatpak/system-repo || true

# Read app IDs and install them
if [ -f /usr/share/flatpak/system-repo/app-ids.txt ]; then
    for appid in $(cat /usr/share/flatpak/system-repo/app-ids.txt); do
        [ -z "$appid" ] && continue
        echo "Installing $appid from local repo..."
        flatpak install --system -y pureblue-local "$appid" || echo "Failed to install $appid"
    done
fi
