#!/bin/bash

set -euo pipefail

BASE_IMAGE="ghcr.io/pureblue-os/gnome:latest"
FINAL_TAG="${1:-localhost/pureblue:latest}"

bash "$(dirname "$0")/build.sh" "$BASE_IMAGE" "$FINAL_TAG"
