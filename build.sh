#!/bin/bash

set -euo pipefail

# Arguments
BASE_IMAGE=${1:-ghcr.io/pureblue-os/gnome:latest}
FINAL_IMAGE=${2:-localhost/pureblue:latest}

echo "==> Building container from $BASE_IMAGE to $FINAL_IMAGE"

# echo "==> Building flatpaks layer"
# ./flatpak/build-repo.sh "$BASE_IMAGE"

TEMP_IMAGE="localhost/pureblue:building-$$"

echo "==> Building packages layer"
podman build --build-arg BASE_IMAGE="$BASE_IMAGE" -f Containerfile.packages -t "$TEMP_IMAGE" .

echo "==> Building extensions layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.extensions -t "$TEMP_IMAGE" .

echo "==> Building tweaks layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.tweaks -t "$TEMP_IMAGE" .

echo "==> Building final layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.final -t "$TEMP_IMAGE" .

# Tag final image
echo "==> Tagging as $FINAL_IMAGE"
podman tag "$TEMP_IMAGE" "$FINAL_IMAGE"

# Clean up temp tag
podman rmi "$TEMP_IMAGE" || true

echo "==> Build complete: $FINAL_IMAGE"
