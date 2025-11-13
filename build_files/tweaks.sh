#!/bin/bash

set -ouex pipefail

echo "==> Applying system tweaks"

# Create desktop entry for pureblue-update
cat > /usr/share/applications/pureblue-system-update.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=System Update
Comment=Update system, Flatpaks, Distrobox containers, and more
Icon=software-update-available
Categories=System;Utility;
Terminal=true
Exec=/usr/bin/pureblue-update
EOF

echo "==> System tweaks applied"
