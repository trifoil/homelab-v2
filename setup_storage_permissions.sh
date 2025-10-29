#!/bin/bash

set -euo pipefail

echo "Configuring /storage permissions and SELinux labels..."

# Ensure base directories exist
mkdir -p /storage/primary/portainer/data
mkdir -p /storage/primary/filebrowser/config
mkdir -p /storage/dockge/{data,stacks,watchtower}
mkdir -p /storage/secondary

# Ownership:
# - Secondary stacks (app data) run as uid:gid 1000 typically (e.g., n8n)
chown -R 1000:1000 /storage/secondary || true

# Permissions: allow read/write/execute for owner & group; read/execute for others
chmod -R 775 /storage/secondary || true
chmod -R 775 /storage/dockge || true
chmod -R 775 /storage/primary/portainer || true
chmod -R 775 /storage/primary/filebrowser || true

# SELinux context for Docker. Prefer :z on mounts; still normalize context here if tools exist
if command -v restorecon >/dev/null 2>&1; then
  restorecon -Rv /storage || true
fi

if command -v semanage >/dev/null 2>&1; then
  semanage fcontext -a -t container_file_t "/storage(/.*)?" || true
  restorecon -Rv /storage || true
fi

echo "Storage permissions configured."


