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
# GENERATE CLEANUP SCRIPT (INLINE COMMANDS, NO LOOP)
################################################################################

{
    echo "#!/bin/bash"
    echo "set -euo pipefail"
    echo ""

    # Pureblue detection — use real installer path
    echo "if [ -f \"$INSTALLER_PATH\" ]; then"
    echo "    exit 0"
    echo "fi"
    echo ""

    # Inline uninstall commands
    while read -r appid; do
        [ -z "$appid" ] && continue
        echo "echo \"Removing Pureblue flatpak: $appid\""
        echo "flatpak uninstall --system -y \"$appid\" || true"
    done < /usr/share/flatpak/system-repo/app-ids.txt

    echo ""
    echo "rm -f /etc/pureblue-cleaner.sh"
    echo "rm -f /etc/systemd/system/pureblue-cleaner.service"
    echo "systemctl daemon-reload"

} > /etc/pureblue-cleaner.sh

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
