#!/bin/bash
set -euo pipefail

# Remove existing remote if present and add local repo as remote
flatpak remote-delete --system --force pureblue-local 2>/dev/null || true
flatpak remote-add --system --no-gpg-verify pureblue-local file:///usr/share/flatpak/system-repo

# Install or update flatpaks
if [ -f /usr/share/flatpak/system-repo/app-ids.txt ]; then
    while read -r appid; do
        [ -z "$appid" ] && continue
        if flatpak list --system --app --columns=application | grep -qx "$appid"; then
            echo "Updating $appid from local repo..."
            flatpak update --system -y "$appid" || echo "Failed to update $appid"
        else
            echo "Installing $appid from local repo..."
            flatpak install --system -y pureblue-local "$appid" || echo "Failed to install $appid"
        fi
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

# Pureblue detection — check if the app-ids list exists
if [ -f /usr/share/flatpak/system-repo/app-ids.txt ]; then
    # Check for orphaned flatpaks (installed from pureblue-local but not in current app-ids.txt)
    echo "Checking for orphaned Pureblue flatpaks..."
    flatpak list --system --app --columns=application,origin 2>/dev/null | while read -r appid origin; do
        [ -z "$appid" ] && continue
        
        if [ "$origin" = "pureblue-local" ] && ! grep -qx "$appid" /usr/share/flatpak/system-repo/app-ids.txt; then
            echo "Removing orphaned Pureblue flatpak: $appid"
            flatpak uninstall --system -y "$appid" || true
        fi
    done
    exit 0
fi

# If app-ids.txt doesn't exist, we're not on Pureblue anymore
# Find and remove all flatpaks that came from pureblue-local remote (origin is tracked even after remote is deleted)
echo "Pureblue installation not detected, removing all Pureblue flatpaks..."
flatpak list --system --app --columns=application,origin 2>/dev/null | while read -r appid origin; do
    [ -z "$appid" ] && continue
    
    if [ "$origin" = "pureblue-local" ]; then
        echo "Removing Pureblue flatpak: $appid"
        flatpak uninstall --system -y "$appid" || true
    fi
done

# Cleanup: remove service and this script after execution
rm -f /etc/systemd/system/pureblue-cleaner.service
systemctl daemon-reload
rm -f /etc/pureblue-cleaner.sh
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
