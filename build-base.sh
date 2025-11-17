#!/bin/bash

set -euo pipefail

BASE_IMAGE="ghcr.io/pureblue-os/gnome:latest"
IMAGE_ID="pureblue"

bash "$(dirname "$0")/build.sh" "$BASE_IMAGE" "$IMAGE_ID"
