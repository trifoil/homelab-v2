# homelab-v2
Upgraded version of the homelab docker deployment

## Explanations

### 1. Primary containers (primary-stack)

contains :

|Application|Port|Description|
|:--:|:--:|:--:|
|Traefik|80, 443, 8080|Reverse proxy and load balancer with HTTPS support|
|Dockge|5001|Docker compose management UI|
|Watchtower|N/A|Automatic container updates|

the storage has to be in /storage/primary/<servicename>

**Traefik Configuration:**
- HTTP (port 80) redirects to HTTPS
- HTTPS (port 443) with Let's Encrypt support
- Dashboard accessible on port 8080
- Self-signed certificates automatically generated during setup
- Services can be accessed at:
  - Traefik Dashboard: `https://traefik.docker.localhost`
  - Dockge: `https://dockge.docker.localhost`


```sh
sudo dnf install git -y
git clone https://github.com/trifoil/homelab-v2
cd homelab-v2
chmod +x docker_setup.sh setup_traefik.sh
sudo ./docker_setup.sh
```

**Note:** The setup script will automatically:
- Install Docker and Docker Compose
- Create all necessary storage directories
- Generate self-signed TLS certificates for Traefik
- Start Traefik, Dockge, and Watchtower

### 2. Secondary container (all the other stacks)

The storage has to be in /storage/secondary/<stackname>/<servicename>

contains :

|Application|Port|Description|
|:--:|:--:|:--:|
|n8n|?|Workflow automation platform|
|DDNS Updater|?|Dynamic DNS updater|

**Note:** These secondary stacks should use the `proxy` network and add Traefik labels to be accessible through Traefik's reverse proxy.