#!/bin/bash

set -euo pipefail

echo "Configuring /storage permissions and SELinux labels..."

# Ensure base directories exist
mkdir -p /storage/primary/portainer/data
mkdir -p /storage/primary/filebrowser/config
mkdir -p /storage/primary/ddns-updater
mkdir -p /storage/primary/ddns-updater/data
mkdir -p /storage/dockge/{data,stacks,watchtower}
mkdir -p /storage/secondary/n8n/data

# Set ownership for primary services
chown -R 1000:1000 /storage/primary || true 

# Fix: Set proper ownership for n8n directory
echo "Setting ownership for n8n data directory..."
chown -R 1000:1000 /storage/secondary/n8n/data || true
chown -R 1000:1000 /storage/secondary || true


# For other secondary stacks, keep generic permissions but ensure directories exist
find /storage/secondary -type d -exec chmod 2775 {} \; || true
find /storage/secondary -type f -exec chmod 0664 {} \; || true

# Specific permissions for n8n
chmod -R 775 /storage/secondary/n8n/data || true

# Keep remaining permissions the same for primary and other areas
chmod -R 775 /storage/dockge || true
chmod -R 775 /storage/primary/portainer || true
chmod -R 775 /storage/primary/filebrowser || true
chmod -R 775 /storage/primary/ddns-updater || true
chmod -R 777 /storage/primary/ddns-updater/data || true

# SELinux context for Docker
if command -v restorecon >/dev/null 2>&1; then
  restorecon -Rv /storage || true
fi

if command -v semanage >/dev/null 2>&1; then
  semanage fcontext -a -t container_file_t "/storage(/.*)?" || true
  restorecon -Rv /storage || true
fi

echo "Storage permissions configured."