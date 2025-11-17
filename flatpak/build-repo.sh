#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASE_IMAGE=${1:?required}
OUTPUT_IMAGE=${2:?required}

# List of flatpak bundle URLs to install (one per line)
# Format: "https://example.com/app.flatpak"
FLATPAK_BUNDLES=(
    "https://github.com/pureblue-os/purestore/releases/download/v0.5.11.pure.20251117.2f85df4/Store.flatpak"
)

# Convert array to space-separated string
FLATPAK_BUNDLE_LIST="${FLATPAK_BUNDLES[*]}"

echo "[+] Building container to fetch flatpaks..."
echo "    Bundles: $FLATPAK_BUNDLE_LIST"
podman rmi flatpakrepo:built || true
podman build \
    --build-arg FLATPAK_BUNDLE_LIST="$FLATPAK_BUNDLE_LIST" \
    -f Containerfile.repo \
    -t flatpakrepo:built \
    "$SCRIPT_DIR"

# TODO: Add chunking support with chunk-layer.sh if needed
# $SCRIPT_DIR/chunk-layer.sh flatpakrepo:built flatpakrepo:chunked 50

echo "[+] Building final flatpak layer..."
podman build \
  --build-arg BASE_IMAGE="$BASE_IMAGE" \
  --build-arg REPO_IMAGE="flatpakrepo:built" \
  -f Containerfile.copy \
  -t "$OUTPUT_IMAGE" \
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