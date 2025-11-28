#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASE_IMAGE=${1:?required}
IMAGE_ID=${2:?required}
FINAL_IMAGE="localhost/${IMAGE_ID}:latest"

echo "==> Building container from $BASE_IMAGE to $FINAL_IMAGE (IMAGE_ID: $IMAGE_ID)"

TEMP_IMAGE="localhost/pureblue:building-$$"

echo "==> Building cleanup layer"
podman build --build-arg BASE_IMAGE="$BASE_IMAGE" -f Containerfile.cleanup -t "$TEMP_IMAGE" .

echo "==> Building flatpaks layer"
"$SCRIPT_DIR/flatpak/build-repo.sh" "$TEMP_IMAGE" "$TEMP_IMAGE"

echo "==> Building packages layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.packages -t "$TEMP_IMAGE" .

echo "==> Building extensions layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.extensions -t "$TEMP_IMAGE" .

echo "==> Building tweaks layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.tweaks -t "$TEMP_IMAGE" .

echo "==> Building services layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.services -t "$TEMP_IMAGE" .

echo "==> Building final layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" -f Containerfile.final -t "$TEMP_IMAGE" .

echo "==> Building brand layer"
podman build --build-arg BASE_IMAGE="$TEMP_IMAGE" --build-arg IMAGE_ID="$IMAGE_ID" -f Containerfile.brand -t "$TEMP_IMAGE" .

# Tag final image
echo "==> Tagging as $FINAL_IMAGE"
podman tag "$TEMP_IMAGE" "$FINAL_IMAGE"

# Clean up temp tag
podman rmi "$TEMP_IMAGE" || true

echo "==> Build complete: $FINAL_IMAGE"
