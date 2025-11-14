#!/bin/bash

set -ouex pipefail

echo "==> Installing system flatpaks"

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo

# Download and install purebazaar flatpak
echo "==> Downloading purebazaar flatpak"
curl -L -o /tmp/purebazaar.flatpak https://github.com/pureblue-os/purebazaar/actions/runs/19352801501/artifacts/4564087830
if [[ -f /tmp/purebazaar.flatpak ]]; then
    echo "==> Installing purebazaar from downloaded file"
    flatpak install --system -y --bundle /tmp/purebazaar.flatpak
    rm -f /tmp/purebazaar.flatpak
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
