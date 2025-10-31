# homelab-v2
Upgraded version of the homelab docker deployment

## Explanations

### 1. Primary stack

contains :

|Application|Port|Description|
|:--:|:--:|:--:|
|Traefik|80, 8080|Reverse proxy and load balancer (HTTP in LAN)|
|Dockge|5001|Docker compose management UI|
|Portainer|9000|Docker management UI (logs, shells, debug) |
|FileBrowser|8086|Web file manager over `/storage`|
|Watchtower|N/A|Automatic container updates|

the storage has to be in /storage/primary/<servicename>

**Traefik Configuration (HTTP-only):**
- HTTP served on port 80 (no HTTPS, no TLS)
- Dashboard accessible on port 8080
- Services can be accessed at:
  - Traefik Dashboard: `http://localhost:8080`
  - Dockge: `http://dockge.docker.localhost` or `http://localhost:5001`
  - Portainer: `https://localhost:9443` (default) or `http://portainer.docker.localhost` / `http://localhost:9000`
  - FileBrowser: `http://filebrowser.docker.localhost` or `http://localhost:8086`

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

### 2. Secondary stacks

The storage has to be in /storage/secondary/<stackname>/<servicename>

contains :

|Application|Port|Description|
|:--:|:--:|:--:|
|n8n|?|Workflow automation platform|
|DDNS Updater|?|Dynamic DNS updater|

**Note:** These secondary stacks should use the `proxy` network and add Traefik labels to be accessible through Traefik's reverse proxy.