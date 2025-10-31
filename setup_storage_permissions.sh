#!/bin/bash

set -euo pipefail

echo "Configuring /storage permissions and SELinux labels..."

# Ensure base directories exist
mkdir -p /storage/primary/portainer/data
mkdir -p /storage/primary/filebrowser/config
mkdir -p /storage/primary/ddns-updater
mkdir -p /storage/primary/ddns-updater/data
mkdir -p /storage/dockge/{data,stacks,watchtower}
mkdir -p /storage/secondary

# Ownership:
# - Do not force ownership on /storage/secondary to stay generic for Dockge-installed stacks
chown -R 1000:1000 /storage/primary || true 

echo "Setting permissive 2777 on /storage/secondary (recursive)..."
# 2777 on directories (setgid + sticky + world-writable), 0666 on files
find /storage/secondary -type d -exec chmod 2777 {} \; || true
find /storage/secondary -type f -exec chmod 0666 {} \; || true

# No ACLs: keep generic and rely on world-writable perms per request

# Keep remaining permissions the same for primary and other areas
chmod -R 775 /storage/dockge || true
chmod -R 775 /storage/primary/portainer || true
chmod -R 775 /storage/primary/filebrowser || true
chmod -R 775 /storage/primary/ddns-updater || true
chmod -R 777 /storage/primary/ddns-updater/data || true
# SELinux context for Docker. Prefer :z on mounts; still normalize context here if tools exist
if command -v restorecon >/dev/null 2>&1; then
  restorecon -Rv /storage || true
fi

if command -v semanage >/dev/null 2>&1; then
  semanage fcontext -a -t container_file_t "/storage(/.*)?" || true
  restorecon -Rv /storage || true
fi

echo "Storage permissions configured."


