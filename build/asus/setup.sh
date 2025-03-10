#!/bin/bash

cd "$(dirname "$0")"

echo "Setup Asus"
set -x
set -euxo pipefail

# asusctl doesnt support with tuned-ppd at this time.
rpm-ostree override remove tuned-ppd --install power-profiles-daemon

rpm-ostree install asusctl asusctl-rog-gui