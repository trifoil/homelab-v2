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
# - All secondary stacks (app data) should run as uid:gid 1000 for best interoperability
# - 2775 on directories ensures group-writability and setgid for collaborative writes
chown -R 1000:1000 /storage/secondary || true
chown -R 1000:1000 /storage/primary || true 

# Permissions: allow read/write/execute for owner & group; setgid for group inheritance
echo "Setting setgid and permissions on /storage/secondary..."
chmod -R 2775 /storage/secondary || true
find /storage/secondary -type d -exec chmod 2775 {} \; || true

# Ensure ACLs are available and set permissive defaults so containers can write even if Dockge
# or other tools create new directories as root after this script runs.
if ! command -v setfacl >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    dnf -y install acl || true
  elif command -v apt-get >/dev/null 2>&1; then
    apt-get update -y && apt-get install -y acl || true
  fi
fi

if command -v setfacl >/dev/null 2>&1; then
  echo "Applying ACLs on /storage/secondary (u:1000 rwx; others rwx; and defaults)..."
  # Effective ACLs
  setfacl -R -m u:1000:rwx /storage/secondary || true
  setfacl -R -m o:rwx /storage/secondary || true
  # Default ACLs for inheritance on newly created files/dirs
  setfacl -R -m d:u:1000:rwx /storage/secondary || true
  setfacl -R -m d:o:rwx /storage/secondary || true
fi

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


