#!/bin/bash

set -euo pipefail

# Arguments
BASE_IMAGE=${1:-ghcr.io/pureblue-os/gnome:latest}
FINAL_IMAGE=${2:-localhost/pureblue:latest}

echo "==> Building container from $BASE_IMAGE to $FINAL_IMAGE"

# echo "==> Building flatpaks layer"
# ./flatpak/build-repo.sh "$BASE_IMAGE"

echo "==> Building packages layer"
podman build --build-arg BASE_IMAGE="$BASE_IMAGE" -f Containerfile.packages -t "$BASE_IMAGE" .

echo "==> Building extensions layer"
podman build --build-arg BASE_IMAGE="$BASE_IMAGE" -f Containerfile.extensions -t "$BASE_IMAGE" .

echo "==> Building tweaks layer"
podman build --build-arg BASE_IMAGE="$BASE_IMAGE" -f Containerfile.tweaks -t "$BASE_IMAGE" .

echo "==> Building final layer"
podman build --build-arg BASE_IMAGE="$BASE_IMAGE" -f Containerfile.final -t "$BASE_IMAGE" .

# Tag final image
echo "==> Tagging as $FINAL_IMAGE"
podman tag "$BASE_IMAGE" "$FINAL_IMAGE"

# Clean up temp tag
podman rmi "$BASE_IMAGE" || true

echo "==> Build complete: $FINAL_IMAGE"
