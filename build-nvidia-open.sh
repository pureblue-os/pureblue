#!/bin/bash

set -euo pipefail

export BASE_IMAGE="ghcr.io/pureblue-os/gnome-nvidia-open:latest"

bash "$(dirname "$0")/build.sh"
