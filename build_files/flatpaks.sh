#!/bin/bash

set -ouex pipefail

echo "==> Installing system flatpaks"

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

# Download and install purebazaar flatpak
# GitHub artifacts are served as ZIP files containing the actual flatpak
echo "==> Downloading purebazaar flatpak"
curl -L -o /tmp/purebazaar.zip https://github.com/pureblue-os/purebazaar/actions/runs/19352801501/artifacts/4564087830
if [[ -f /tmp/purebazaar.zip ]]; then
    echo "==> Extracting purebazaar archive"
    unzip -q /tmp/purebazaar.zip -d /tmp/purebazaar_extracted
    # Find the actual flatpak file inside the extracted contents
    FLATPAK_FILE=$(find /tmp/purebazaar_extracted -name "*.flatpak" | head -n 1)
    if [[ -f "$FLATPAK_FILE" ]]; then
        echo "==> Installing purebazaar from extracted file"
        flatpak install --system -y --bundle "$FLATPAK_FILE"
    else
        echo "ERROR: No flatpak file found in extracted archive"
        exit 1
    fi
    rm -rf /tmp/purebazaar_extracted /tmp/purebazaar.zip
fi

# Install system flatpaks
flatpak install --system -y flathub com.usebottles.bottles
flatpak install --system -y flathub io.github.dvlv.boxbuddyrs
flatpak install --system -y flathub it.mijorus.gearlever
flatpak install --system -y flathub io.github.flattool.Ignition
flatpak install --system -y flathub com.github.tchx84.Flatseal
flatpak install --system -y flathub io.github.giantpinkrobots.flatsweep
flatpak install --system -y flathub com.mattjakeman.ExtensionManager
flatpak install --system -y flathub page.tesk.Refine
flatpak install --system -y flathub org.onlyoffice.desktopeditors

echo "==> System flatpaks installation complete"
