#!/bin/bash

set -e  # Exit on error

REMOTE_IMAGE_NAME_PREFIX="ghcr.io/pureblue-os/pureblue"
DEFAULT_IMAGE_TAGS=("latest" "41")

BUILD_DIR="build"
BUILDING=()
PUBLISH=false

./chmod-x-all.sh

get_image_name() {
    local IMAGE_NAME="$1"
    local REMOTE_IMAGE_NAME="$REMOTE_IMAGE_NAME_PREFIX-$IMAGE_NAME"
    echo "$REMOTE_IMAGE_NAME"
}

publish_image() {
    local IMAGE_NAME="$1"
    local REMOTE_IMAGE_NAME="$(get_image_name "$IMAGE_NAME")"
    local IMAGE_DIR="$BUILD_DIR/$IMAGE_NAME"
    
    IMAGE_TAGS=()
    if [[ -f "$IMAGE_DIR/tags" ]]; then
        while IFS= read -r TAG || [[ -n "$TAG" ]]; do
            IMAGE_TAGS+=("$TAG")
        done < "$IMAGE_DIR/tags"
    fi
    IMAGE_TAGS+=("${DEFAULT_IMAGE_TAGS[@]}")

    for TAG in "${IMAGE_TAGS[@]}"; do
        echo "Pushing $IMAGE_NAME as $REMOTE_IMAGE_NAME:$TAG..."
        podman tag "$REMOTE_IMAGE_NAME:latest" "$REMOTE_IMAGE_NAME:$TAG"
        podman push "$REMOTE_IMAGE_NAME:$TAG"
    done
}

build_image() {
    local IMAGE_NAME="$1"
    local REMOTE_IMAGE_NAME="$(get_image_name "$IMAGE_NAME")"
    local IMAGE_DIR="$BUILD_DIR/$IMAGE_NAME"

    if [[ " ${BUILDING[@]} " =~ " $IMAGE_NAME " ]]; then
        echo "Error: Detected circular dependency or duplicate build: $IMAGE_NAME"
        exit 1
    fi

    BUILDING+=("$IMAGE_NAME")

    if [[ -f "$IMAGE_DIR/deps" ]]; then
        while IFS= read -r DEP || [[ -n "$DEP" ]]; do
            if [[ ! " ${BUILDING[@]} " =~ " $DEP " ]]; then
                build_image "$DEP"
            fi
        done < "$IMAGE_DIR/deps"
    fi

    # podman pull "$REMOTE_IMAGE_NAME:latest" || true

    echo "Building $IMAGE_NAME..."
    podman build \
        -f "$IMAGE_DIR/Containerfile" ./build \
        --tag "$REMOTE_IMAGE_NAME:latest" \
        --build-arg REMOTE_IMAGE_NAME_PREFIX=$REMOTE_IMAGE_NAME_PREFIX

    publish_image "$IMAGE_NAME"

    BUILDING=( "${BUILDING[@]/$IMAGE_NAME}" )
}

IMAGE_NAMES=($(ls -d $BUILD_DIR/*/ | xargs -n 1 basename))
for IMAGE_NAME in "${IMAGE_NAMES[@]}"; do
    build_image "$IMAGE_NAME"
done
