#!/bin/bash

set -euo pipefail

# Arguments
BASE_IMAGE=${1:-ghcr.io/pureblue-os/gnome:latest}
FINAL_TAG=${2:-localhost/pureblue:latest}
TEMP_TAG="pureblue:building-$$"

echo "==> Building container from $BASE_IMAGE to $FINAL_TAG"

# Build each layer incrementally
echo "==> Building flatpaks layer"
podman build --build-arg BASE_IMAGE="$TEMP_TAG" -f Containerfile.flatpaks -t "$TEMP_TAG" .

echo "==> Building packages layer"
podman build --build-arg BASE_IMAGE="$TEMP_TAG" -f Containerfile.packages -t "$TEMP_TAG" .

echo "==> Building extensions layer"
podman build --build-arg BASE_IMAGE="$TEMP_TAG" -f Containerfile.extensions -t "$TEMP_TAG" .

echo "==> Building tweaks layer"
podman build --build-arg BASE_IMAGE="$TEMP_TAG" -f Containerfile.tweaks -t "$TEMP_TAG" .

echo "==> Building final layer"
podman build --build-arg BASE_IMAGE="$TEMP_TAG" -f Containerfile.final -t "$TEMP_TAG" .

# Tag final image
echo "==> Tagging as $FINAL_TAG"
podman tag "$TEMP_TAG" "$FINAL_TAG"

# Clean up temp tag
podman rmi "$TEMP_TAG" || true

echo "==> Build complete: $FINAL_TAG"
