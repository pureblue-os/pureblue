#!/bin/bash

set -ouex pipefail

echo "==> Installing GNOME extensions"

# Get GNOME Shell version
GNOME_VERSION=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)

# Function to install extension from extensions.gnome.org
install_extension() {
    local EXTENSION_UUID=$1
    
    echo "Installing extension: ${EXTENSION_UUID}"
    
    # Get extension info using UUID
    local INFO_URL="https://extensions.gnome.org/extension-info/?uuid=${EXTENSION_UUID}"
    local EXTENSION_INFO=$(curl -sL "${INFO_URL}")
    
    # Extract version pk for current GNOME version
    local VERSION_PK=$(echo "${EXTENSION_INFO}" | grep -o "\"${GNOME_VERSION}\": {\"pk\": [0-9]*" | grep -o "[0-9]*$" | head -1)
    
    if [ -z "${VERSION_PK}" ]; then
        echo "Warning: Extension ${EXTENSION_UUID} not available for GNOME ${GNOME_VERSION}, skipping"
        return 0
    fi
    
    # Download and install
    local DOWNLOAD_URL="https://extensions.gnome.org/download-extension/${EXTENSION_UUID}.shell-extension.zip?version_tag=${VERSION_PK}"
    local TEMP_FILE="/tmp/${EXTENSION_UUID}.zip"
    
    curl -sL "${DOWNLOAD_URL}" -o "${TEMP_FILE}"
    
    mkdir -p "/usr/share/gnome-shell/extensions/${EXTENSION_UUID}"
    unzip -q -o "${TEMP_FILE}" -d "/usr/share/gnome-shell/extensions/${EXTENSION_UUID}"
    rm "${TEMP_FILE}"
    
    echo "Installed: ${EXTENSION_UUID}"
}

# Install curl and unzip for downloading extensions
dnf5 install -y curl unzip

# Install GSConnect from package repository
dnf5 install -y gnome-shell-extension-gsconnect

# Install extensions from extensions.gnome.org
install_extension "tweaks-system-menu@extensions.gnome-shell.fifi.org"
install_extension "tilingshell@ferrarodomenico.com"
install_extension "legacyschemeautoswitcher@joshimukul29.gmail.com"
install_extension "do-not-disturb-while-screen-sharing-or-recording@marcinjahn.com"
install_extension "clipboard-indicator@tudmotu.com"
install_extension "boostvolume@shaquib.dev"
install_extension "volume_scroller@francislavoie.github.io"

# Fix permissions on extension files
chmod -R a+r /usr/share/gnome-shell/extensions/
find /usr/share/gnome-shell/extensions/ -type d -exec chmod a+rx {} \;

# Compile schemas for extensions that have them
for ext_dir in /usr/share/gnome-shell/extensions/*/; do
    if [ -d "${ext_dir}schemas" ]; then
        glib-compile-schemas "${ext_dir}schemas/"
    fi
done

echo "==> GNOME extensions installation complete"
