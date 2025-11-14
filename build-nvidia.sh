#!/bin/bash

set -euo pipefail

BASE_IMAGE="ghcr.io/pureblue-os/gnome-nvidia:latest"
FINAL_IMAGE="${1:-localhost/pureblue:latest}"

bash "$(dirname "$0")/build.sh" "$BASE_IMAGE" "$FINAL_IMAGE"
