# Quick Start - Kubernetes Development

This project uses **Kubernetes (k3d) + Tilt** for local development.

## First Time Setup

### 1. Run the host setup script

Choose the script for your platform:

**WSL2 / Linux:**
```bash
./scripts/host/setup-k8s-linux.sh
```

**macOS:**
```bash
./scripts/host/setup-k8s-macos.sh
```

Both scripts handle everything automatically:
- Install essential prerequisites (curl, git, ca-certificates)
- Install Docker (Docker Engine on Linux, Colima on macOS)
- Install kubectl
- Install k3d
- Create a local Kubernetes cluster with a container registry

**Notes:**
- **WSL2:** Requires systemd enabled (Ubuntu 22.04+ on Windows 11 has this by default). The script will check and provide instructions if needed.
- **Linux:** If Docker was just installed, log out and back in (or run `newgrp docker`) before continuing.
- **macOS:** Uses Colima (lightweight Docker runtime). The script starts it automatically.

### 2. Open the devcontainer

1. Open the project in VS Code
2. When prompted, click **"Reopen in Container"** (or F1 → "Dev Containers: Reopen in Container")
3. Wait for the devcontainer to build

### 3. Start the development stack

```bash
tilt up
```

Press **space** to open the Tilt UI in your browser.

## Accessing Services

Once `tilt up` is running:

- **Web (Frontend)**: http://localhost:5173
- **API (Backend)**: http://localhost:8080/health
- **Browser (noVNC)**: http://localhost:6080
- **Tilt UI**: http://localhost:10350
- **PostgreSQL**: localhost:5432 (user: `mariner`, password: `mariner`)

## Daily Workflow

### Starting Development

```bash
# In the devcontainer terminal
tilt up
```

### Making Changes

- **Web changes**: Edit files in `web/src/` - Vite hot-reloads instantly
- **API changes**: Edit files in `api/src/` - Tilt rebuilds and restarts
- **Database**: Connect via `psql -h localhost -p 5432 -U mariner -d mariner`

### Viewing Logs

Use the Tilt UI (recommended) or kubectl:

```bash
kubectl logs -f <pod-name> -n mariner-dev
```

### Stopping Services

```bash
# Press Ctrl+C in the tilt up terminal, or
tilt down
```

## Useful Commands

```bash
# Check cluster status
kubectl get nodes

# View all pods
kubectl get pods -n mariner-dev

# View pod details
kubectl describe pod <pod-name> -n mariner-dev

# Execute command in pod
kubectl exec -it <pod-name> -n mariner-dev -- /bin/bash
```

## Troubleshooting

### WSL2: "systemd is not available" (during setup)

WSL2 requires systemd for Docker. To enable it:

```bash
# Create/edit wsl.conf
sudo bash -c 'echo -e "[boot]\nsystemd=true" > /etc/wsl.conf'

# Then from PowerShell (on Windows), restart WSL:
wsl --shutdown

# Re-open WSL terminal and run setup again
```

### "Cannot connect to Kubernetes cluster"

The cluster runs on your host. Make sure it's running:

```bash
# On your host (not in devcontainer)
k3d cluster list

# If not running, start it:
k3d cluster start mariner-dev

# Or recreate it (choose your platform):
./scripts/host/setup-k8s-linux.sh   # WSL2/Linux
./scripts/host/setup-k8s-macos.sh   # macOS
```

### "Can't connect to services"

```bash
# Verify pods are running
kubectl get pods -n mariner-dev

# Check pod logs
kubectl logs <pod-name> -n mariner-dev

# Restart Tilt
tilt down
tilt up
```

### "Out of disk space"

```bash
# Clean up Docker (on host)
docker system prune -a

# Delete and recreate cluster (on host)
k3d cluster delete mariner-dev
./scripts/host/setup-k8s-linux.sh   # or setup-k8s-macos.sh
```

## Learn More

- [Tilt Documentation](https://docs.tilt.dev/)
- [k3d Documentation](https://k3d.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [k8s/README.md](k8s/README.md) - Detailed architecture documentation
