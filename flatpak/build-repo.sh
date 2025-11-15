#!/usr/bin/env bash
set -euo pipefail

BASE_IMAGE=${1:?BASE_IMAGE argument required}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of flatpak IDs to install (one per line)
FLATPAK_APPS=(
    "page.tesk.Refine"
    "com.mattjakeman.ExtensionManager"
)

# Convert array to space-separated string
FLATPAK_LIST="${FLATPAK_APPS[*]}"

echo "[+] Building container to fetch flatpaks..."
echo "    Apps: $FLATPAK_LIST"
podman rmi flatpakrepo:unchunked || true
podman build \
    --build-arg FLATPAK_LIST="$FLATPAK_LIST" \
    -f Containerfile.repo \
    -t flatpakrepo:unchunked \
    "$SCRIPT_DIR"

$SCRIPT_DIR/chunk-layer.sh flatpakrepo:unchunked flatpakrepo:chunked 50

podman build \
  --build-arg BASE_IMAGE="$BASE_IMAGE" \
  --build-arg REPO_IMAGE="flatpakrepo:chunked" \
  -f Containerfile.copy \
  -t "$BASE_IMAGE" \
  "$SCRIPT_DIR"



########
# ARG BASE_IMAGE
# FROM ${BASE_IMAGE}
# 
# RUN flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# 
# RUN curl -L -o /tmp/purebazaar.flatpak https://github.com/pureblue-os/purebazaar/releases/download/v0.5.11.pure.20251114/Bazaar.flatpak && \
#     flatpak install --system -y --bundle /tmp/purebazaar.flatpak && \
#     rm -f /tmp/purebazaar.flatpak && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# 
# RUN flatpak install --system -y flathub com.usebottles.bottles && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub io.github.dvlv.boxbuddyrs && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub it.mijorus.gearlever && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub io.github.flattool.Ignition && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub com.github.tchx84.Flatseal && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub io.github.giantpinkrobots.flatsweep && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub com.mattjakeman.ExtensionManager && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub page.tesk.Refine && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*
# RUN flatpak install --system -y flathub org.onlyoffice.desktopeditors && \
#     rm -rf /var/lib/flatpak/repo/tmp/cache/* /var/tmp/flatpak-cache-* /root/.local/share/flatpak/repo/tmp/cache/*