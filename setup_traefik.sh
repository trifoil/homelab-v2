#!/bin/bash

# Check if openssl is installed
if ! command -v openssl &> /dev/null; then
    echo "openssl not found. Installing..."
    if command -v dnf &> /dev/null; then
        dnf -y install openssl
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get -y install openssl
    else
        echo "Error: Cannot install openssl. Please install it manually."
        exit 1
    fi
fi

# Setup directories for Traefik
echo "Setting up Traefik directories..."
mkdir -p /storage/primary/traefik/certs
mkdir -p /storage/primary/traefik/dynamic
mkdir -p /storage/primary/traefik/letsencrypt

# Generate self-signed certificate
echo "Generating self-signed certificate..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /storage/primary/traefik/certs/local.key \
  -out /storage/primary/traefik/certs/local.crt \
  -subj "/CN=*.docker.localhost"

# Create TLS configuration file
echo "Creating TLS configuration..."
cat > /storage/primary/traefik/dynamic/tls.yml << 'EOF'
tls:
  certificates:
    - certFile: /certs/local.crt
      keyFile: /certs/local.key
EOF

# Create acme.json for Let's Encrypt
echo "Creating Let's Encrypt storage file..."
touch /storage/primary/traefik/letsencrypt/acme.json
chmod 600 /storage/primary/traefik/letsencrypt/acme.json

echo "Traefik setup complete!"
