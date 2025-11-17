#!/bin/bash
set -euo pipefail

# Get absolute path of THIS script (dynamic, no hardcoding)
INSTALLER_PATH=$(readlink -f "$0")

# Remove existing remote if present and add local repo as remote
flatpak remote-delete --system --force pureblue-local 2>/dev/null || true
flatpak remote-add --system --no-gpg-verify pureblue-local file:///usr/share/flatpak/system-repo

# Install flatpaks
if [ -f /usr/share/flatpak/system-repo/app-ids.txt ]; then
    while read -r appid; do
        [ -z "$appid" ] && continue
        echo "Installing $appid from local repo..."
        flatpak install --system -y pureblue-local "$appid" || echo "Failed to install $appid"
    done < /usr/share/flatpak/system-repo/app-ids.txt
fi

# Remove the temporary remote
flatpak remote-delete --system --force pureblue-local 2>/dev/null || true


################################################################################
# GENERATE CLEANUP SCRIPT (QUERIES FLATPAK FOR APPS FROM pureblue-local)
################################################################################

cat > /etc/pureblue-cleaner.sh << 'CLEANUP_EOF'
#!/bin/bash
set -euo pipefail

# Pureblue detection — use real installer path
if [ -f "$INSTALLER_PATH" ]; then
    exit 0
fi

# Find and remove all flatpaks that came from pureblue-local remote
echo "Searching for Pureblue flatpaks to remove..."
flatpak list --system --app --columns=application,origin | while read -r line; do
    appid=$(echo "$line" | awk '{print $1}')
    origin=$(echo "$line" | awk '{print $2}')
    
    if [ "$origin" = "pureblue-local" ]; then
        echo "Removing Pureblue flatpak: $appid"
        flatpak uninstall --system -y "$appid" || true
    fi
done

rm -f /etc/pureblue-cleaner.sh
rm -f /etc/systemd/system/pureblue-cleaner.service
systemctl daemon-reload
CLEANUP_EOF

chmod +x /etc/pureblue-cleaner.sh


################################################################################
# SYSTEMD UNIT FOR CLEANER
################################################################################

cat > /etc/systemd/system/pureblue-cleaner.service << 'EOF'
[Unit]
Description=Cleanup Pureblue OS flatpaks when Pureblue image is not present

[Service]
Type=oneshot
ExecStart=/etc/pureblue-cleaner.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable pureblue-cleaner.service
