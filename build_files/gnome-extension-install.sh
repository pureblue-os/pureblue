#!/bin/bash

set -euo pipefail

# Get GNOME version once
GNOME_VERSION=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)

install_extension() {
    local UUID=$1
    echo "==> Installing extension: ${UUID}"
    
    INFO=$(curl -sL "https://extensions.gnome.org/extension-info/?uuid=${UUID}")
    PK=$(echo "${INFO}" | grep -o "\"${GNOME_VERSION}\": {\"pk\": [0-9]*" | grep -o "[0-9]*$" | head -1)
    
    if [ -n "${PK}" ]; then
        curl -sL "https://extensions.gnome.org/download-extension/${UUID}.shell-extension.zip?version_tag=${PK}" -o "/tmp/${UUID}.zip"
        mkdir -p "/usr/share/gnome-shell/extensions/${UUID}"
        unzip -q -o "/tmp/${UUID}.zip" -d "/usr/share/gnome-shell/extensions/${UUID}"
        rm "/tmp/${UUID}.zip"
        echo "==> Successfully installed ${UUID}"
    else
        echo "==> WARNING: No compatible version found for ${UUID} (GNOME ${GNOME_VERSION})"
        exit 1
    fi
}

# Install each extension passed as argument
for ext in "$@"; do
    install_extension "$ext"
done

# Fix permissions for all extensions
chmod -R a+r /usr/share/gnome-shell/extensions/
find /usr/share/gnome-shell/extensions/ -type d -exec chmod a+rx {} \;

# Compile schemas
for ext_dir in /usr/share/gnome-shell/extensions/*/; do
    if [ -d "${ext_dir}schemas" ]; then
        glib-compile-schemas "${ext_dir}schemas/"
    fi
done

echo "==> All extensions installed successfully"
