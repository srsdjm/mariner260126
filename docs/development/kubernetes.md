# Kubernetes Manifests

This directory contains Kubernetes manifests for the Mariner development environment.

## Overview

The Mariner project uses a **Kubernetes-native development environment** with:
- **k3d** (Lightweight Kubernetes in Docker) for local K8s clusters
- **Tilt** for hot-reloading and development workflow automation
- **DevContainer** for portable, reproducible development environments

See [Networking Architecture](../architecture/networking.md) for details on how the devcontainer connects to the k3d cluster.

## Files

- [namespace.yaml](../../k8s/namespace.yaml) - Creates the `mariner-dev` namespace
- [database.yaml](../../k8s/database.yaml) - PostgreSQL database with persistent storage
- [api.yaml](../../k8s/api.yaml) - Ktor API backend with health checks and JDWP debugging
- [web.yaml](../../k8s/web.yaml) - React/Vite frontend with hot reload
- [browser.yaml](../../k8s/browser.yaml) - Playwright browser automation with noVNC

## Getting Started

### Prerequisites

**On your host machine** (before opening devcontainer), run:

- **WSL2/Linux**: `./scripts/host/setup-k8s-linux.sh`
- **macOS**: `./scripts/host/setup-k8s-macos.sh`

These scripts install and configure:
- Docker (Docker Engine on Linux, Colima on macOS)
- kubectl (Kubernetes CLI)
- k3d (Lightweight Kubernetes in Docker)
- Creates a k3d cluster named `mariner-dev`
- Sets up a local Docker registry at `localhost:5005`

### Starting the Environment

1. Run the host setup script (see Prerequisites above)
2. Open the project in VS Code with the DevContainer extension
3. Click "Reopen in Container" when prompted
4. Wait for the devcontainer to build and start

4. Start all services:
   ```bash
   tilt up
   ```

5. Access the Tilt UI at http://localhost:10350 to monitor services

### Available Services

Once running, services are available at:

- **Web (React/Vite)**: http://localhost:5173
- **API (Ktor)**: http://localhost:8080/health
- **Browser (noVNC)**: http://localhost:6080
- **Tilt UI**: http://localhost:10350
- **PostgreSQL**: localhost:5432 (user: mariner, password: mariner)
- **JDWP Debugger**: localhost:5005

## Development Workflow

### Hot Reload

Tilt automatically watches for file changes and updates services:

- **Web**: Changes to `/web/src` trigger instant hot reload (< 2 seconds)
- **API**: Changes to `/api/src` trigger rebuild and restart (< 30 seconds)
- **Docker images**: Tilt rebuilds images when Dockerfiles change

### Viewing Logs

Use the Tilt UI (http://localhost:10350) or kubectl:

```bash
# View all pods
kubectl get pods -n mariner-dev

# View logs for a specific pod
kubectl logs -f <pod-name> -n mariner-dev

# Example: View API logs
kubectl logs -f $(kubectl get pod -n mariner-dev -l app=api -o name) -n mariner-dev
```

### Debugging

#### API Debugging (Java/Kotlin)

The API service exposes JDWP on port 5005:

1. In VS Code, create a debug configuration:
   ```json
   {
     "type": "java",
     "request": "attach",
     "name": "Debug API (JDWP)",
     "hostName": "localhost",
     "port": 5005
   }
   ```

2. Set breakpoints and start debugging

### Database Access

Connect to PostgreSQL using any client:

```bash
# Using psql
psql -h localhost -p 5432 -U mariner -d mariner

# Connection string
postgresql://mariner:mariner@localhost:5432/mariner
```

### Stopping Services

```bash
# Stop all services
tilt down

# Delete the k3d cluster (if needed - run on host)
k3d cluster delete mariner-dev
```

## Architecture

### Namespace

All resources are deployed to the `mariner-dev` namespace to isolate development from other workloads.

### Database (PostgreSQL)

- **Deployment**: Single replica PostgreSQL 16
- **Storage**: 5Gi PersistentVolumeClaim for data persistence
- **Service**: ClusterIP service exposing port 5432
- **Health Checks**: Readiness and liveness probes using `pg_isready`

### API (Ktor)

- **Deployment**: Single replica Kotlin/Ktor application
- **Build**: Gradle multi-stage build
- **Live Updates**: Tilt syncs source files and rebuilds on change
- **Service**: ClusterIP service exposing ports 8080 (HTTP) and 5005 (JDWP)
- **Environment**: Database connection via service discovery
- **Debugging**: JDWP enabled on port 5005

### Web (React/Vite)

- **Deployment**: Single replica Vite dev server
- **Build**: Node.js with multi-stage Dockerfile
- **Live Updates**: Tilt syncs source files for instant hot reload
- **Service**: ClusterIP service exposing port 5173
- **Development**: Vite HMR for fast feedback

### Browser (Playwright)

- **Deployment**: Single replica Playwright with noVNC
- **Service**: ClusterIP service exposing ports 6080 (noVNC), 5900 (VNC), 7331 (MCP)
- **Resources**: 4Gi shared memory for browser operations
- **Security**: SYS_ADMIN capability for sandbox support

## Tilt Configuration

The [Tiltfile](../../Tiltfile) defines:

- Docker image builds with live updates
- Kubernetes resource deployments
- Port forwarding configuration
- Resource dependencies (startup order)
- Resource grouping by labels

## Troubleshooting

### Cluster not responding

```bash
# Check cluster status
kubectl cluster-info

# Verify nodes are ready
kubectl get nodes

# Recreate cluster if needed (run on host, not in devcontainer)
k3d cluster delete mariner-dev
./scripts/host/setup-k8s-linux.sh   # or setup-k8s-macos.sh
```

### Pod not starting

```bash
# Check pod status
kubectl get pods -n mariner-dev

# Describe pod for events
kubectl describe pod <pod-name> -n mariner-dev

# View pod logs
kubectl logs <pod-name> -n mariner-dev
```

### Port conflicts

If ports are already in use, you can modify the port forwards in the [Tiltfile](../Tiltfile) or stop conflicting services.

### Image pull errors

The local registry should be at `localhost:5005`. Verify:

```bash
# Check registry is running
docker ps | grep k3d-mariner-registry

# Test registry
docker pull hello-world
docker tag hello-world localhost:5005/hello-world
docker push localhost:5005/hello-world
```

## Next Steps

See [Migration Status](../architecture/migration-status.md) for:
- Phase 1: Kubernetes Development Workflow enhancements
- Phase 2: Production-ready patterns (ConfigMaps, Secrets, Ingress)
- Migration status and validation checklists
