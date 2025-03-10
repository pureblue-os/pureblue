#!/bin/bash

cd "$(dirname "$0")"

echo "Setup Base"
set -x
set -euxo pipefail

FEDORA_VERSION=$(rpm -E %fedora)

rsync -av ./usr/ /usr/

rpm-ostree override remove firefox firefox-langpacks
rpm-ostree install gnome-tweaks openssl

systemctl enable pureblue.service