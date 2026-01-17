# Kubernetes Manifests

This directory contains Kubernetes manifests for the Mariner development environment.

## Overview

The Mariner project uses a **Kubernetes-native development environment** with:
- **Kind** (Kubernetes in Docker) for local K8s clusters
- **Tilt** for hot-reloading and development workflow automation
- **DevContainer** for portable, reproducible development environments

## Files

- [namespace.yaml](namespace.yaml) - Creates the `mariner-dev` namespace
- [database.yaml](database.yaml) - PostgreSQL database with persistent storage
- [api.yaml](api.yaml) - Ktor API backend with health checks and JDWP debugging
- [web.yaml](web.yaml) - React/Vite frontend with hot reload
- [browser.yaml](browser.yaml) - Playwright browser automation with noVNC

## Getting Started

### Prerequisites

The devcontainer automatically installs:
- kubectl (Kubernetes CLI)
- Kind (Kubernetes in Docker)
- Tilt (development workflow tool)
- Helm (package manager)

### Starting the Environment

1. Open the project in VS Code with the DevContainer extension
2. Wait for the devcontainer to build and start
3. The setup will automatically:
   - Install Kind and Tilt
   - Create a Kind cluster named `mariner-dev`
   - Set up a local Docker registry at `localhost:5005`
   - Show instructions for starting Tilt

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

# Delete the Kind cluster (if needed)
kind delete cluster --name mariner-dev
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

The [Tiltfile](../Tiltfile) defines:

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

# Recreate cluster if needed
kind delete cluster --name mariner-dev
bash .devcontainer/setup-k8s.sh
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
docker ps | grep kind-registry

# Test registry
docker pull hello-world
docker tag hello-world localhost:5005/hello-world
docker push localhost:5005/hello-world
```

## Next Steps

See [K8S_MIGRATION_STATUS.md](../K8S_MIGRATION_STATUS.md) for:
- Phase 1: Kubernetes Development Workflow enhancements
- Phase 2: Production-ready patterns (ConfigMaps, Secrets, Ingress)
- Migration status and validation checklists
