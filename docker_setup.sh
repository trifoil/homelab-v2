#!/bin/bash

dnf -y remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

dnf -y install dnf-plugins-core
dnf-3 -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

echo "Docker installed ..."

echo "Setting up storage directories and permissions..."
sudo bash setup_storage_permissions.sh

# No TLS setup required for HTTP-only Traefik

# Start the Server
echo "Starting services..."
docker compose --project-name "dockge" up -d

echo ""
echo "=============================================="
echo "Setup complete!"
echo ""
echo "Access the services at:"
echo "  - Traefik Dashboard: http://localhost:8080"
echo "  - Dockge (via Traefik): http://dockge.docker.localhost"
echo "  - Dockge (direct): http://localhost:5001"
echo "  - Portainer (via Traefik): http://portainer.docker.localhost"
echo "  - Portainer (direct): http://localhost:9000"
echo "=============================================="

read -n 1 -s -r -p "Press any key to continue..."