#!/bin/bash

cd "$(dirname "$0")"

echo "Setup Asus"
set -x
set -euxo pipefail

wget https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-${FEDORA_VERSION}/lukenukem-asus-linux-fedora-${FEDORA_VERSION}.repo -O /etc/yum.repos.d/_copr_lukenukem-asus-linux.repo

# asusctl doesnt support with tuned-ppd at this time.
rpm-ostree override remove tuned-ppd --install power-profiles-daemon

rpm-ostree install asusctl asusctl-rog-gui