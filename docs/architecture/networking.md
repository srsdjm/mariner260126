# DevContainer + k3d Networking Architecture

This document describes the networking architecture for integrating a DevContainer development environment with a k3d Kubernetes cluster. It covers the architectural decisions, research justification, and implementation details for platform engineers and developers working with this configuration.

## Architecture Overview

This project uses a **cluster-on-host with Docker-outside-of-Docker (DOOD)** pattern where:

1. The k3d cluster runs on the **host machine** (not inside the devcontainer)
2. The devcontainer accesses the host's Docker daemon via socket mount
3. Networking between devcontainer and k3d occurs through the **Docker bridge gateway** (172.17.0.1)
4. TLS certificates are configured with SANs for the gateway IP
5. kubeconfig is automatically fixed on devcontainer startup

### Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│ Host Machine                                                │
│                                                             │
│  ┌──────────────────────────────────────────────┐          │
│  │ k3d Cluster (k3d-mariner-dev network)       │          │
│  │ Network: 172.18.0.0/16                      │          │
│  │                                              │          │
│  │  ┌─────────────────────┐                    │          │
│  │  │ k3d-proxy           │                    │          │
│  │  │ IP: 172.18.0.2      │                    │          │
│  │  │ Exposes: 0.0.0.0:37621→6443             │          │
│  │  │          0.0.0.0:8080→80                 │          │
│  │  │          0.0.0.0:8443→443                │          │
│  │  └─────────────────────┘                    │          │
│  │                                              │          │
│  │  ┌─────────────────────┐                    │          │
│  │  │ k3s-server          │                    │          │
│  │  │ IP: 172.18.0.3      │                    │          │
│  │  │ API: 6443 (internal)│                    │          │
│  │  │ TLS SANs:           │                    │          │
│  │  │   - 172.17.0.1 ✓    │                    │          │
│  │  │   - 127.0.0.1 ✓     │                    │          │
│  │  │   - 0.0.0.0 ✓       │                    │          │
│  │  └─────────────────────┘                    │          │
│  └──────────────────────────────────────────────┘          │
│                                                             │
│  ┌──────────────────────────────────────────────┐          │
│  │ DevContainer (default bridge network)       │          │
│  │ Network: 172.17.0.0/16                      │          │
│  │ Gateway: 172.17.0.1 ←─┐                     │          │
│  │                        │                     │          │
│  │  kubectl configured:   │                     │          │
│  │  server: https://172.17.0.1:37621           │          │
│  │                        │                     │          │
│  │  Accesses k3d API via Docker port forward   │          │
│  └──────────────────────────────────────────────┘          │
│                         │                                   │
│        Port Mapping: 0.0.0.0:37621 → 172.17.0.1:37621     │
└─────────────────────────────────────────────────────────────┘
```

### Key Characteristics

- **Cluster location**: Host machine (persistent across devcontainer rebuilds)
- **Networking method**: Docker bridge gateway
- **TLS configuration**: SANs include gateway IP (172.17.0.1)
- **kubeconfig management**: Automatic fixup in postStart hook
- **Performance**: Single Docker daemon, no nested containers
- **Stability**: Cluster persists, ~5-10s startup time

---

## Design Justification

### Pattern Selection Rationale

This architecture implements the **cluster-on-host with DOOD** pattern, which represents current best practice (2024-2026) for k3d + DevContainer integration based on:

- [Tilt documentation](https://docs.tilt.dev/choosing_clusters.html) recommendations for DOOD patterns
- [k3d networking documentation](https://k3d.io/v5.4.6/design/networking/) guidance for container access
- Real-world implementations in production repositories
- Performance and stability benchmarking vs alternatives

### Alternative Approaches Evaluated

#### 1. k3d Inside DevContainer (Ephemeral Pattern)

**Implementation:**
```json
{
  "features": {
    "ghcr.io/rio/features/k3d:1": {}
  },
  "postCreateCommand": "k3d cluster create mariner-dev --registry-create"
}
```

**Trade-offs:**
- **Pros**: Zero host prerequisites, one-click setup, ideal for GitHub Codespaces
- **Cons**: Cluster recreated on devcontainer rebuild (lost state), 20-30s additional startup time, requires `--network host` which conflicts with registry integration ([k3d#1418](https://github.com/k3d-io/k3d/issues/1418))
- **Use case**: Ephemeral development sessions, CI/CD, Codespaces environments
- **Not chosen because**: Multi-day development sessions require cluster persistence

#### 2. KIND (Kubernetes IN Docker) Alternative

**Comparison:**

| Metric | k3d (chosen) | KIND |
|--------|--------------|------|
| Startup time | 5-10s | 10-20s |
| Memory footprint | Lower (~500MB) | Higher (~1GB) |
| Built-in registry | Yes (native) | No (manual setup) |
| Multi-node support | Limited | Excellent |
| CI/CD adoption | Common | Preferred |
| Kubernetes parity | k3s (lightweight) | Full k8s |

**Not chosen because**: Single-node local development prioritizes fast startup and low memory over multi-node capabilities. KIND offers marginal benefits for this use case.

#### 3. Joining k3d Network Directly

**Implementation:**
```json
{
  "runArgs": ["--network=k3d-mariner-dev"]
}
```

**Trade-offs:**
- **Pros**: Direct network access to k3d components, no gateway routing
- **Cons**: Couples devcontainer lifecycle to k3d network, breaks on cluster recreation, requires devcontainer rebuild when cluster changes, non-standard pattern with few production examples
- **Not chosen because**: Fragile coupling, poor devcontainer portability

#### 4. Docker-in-Docker (DinD)

**Trade-offs:**
- **Cons**: Nested container complexity, requires privileged mode, poor performance, storage driver conflicts, security concerns
- **Not chosen because**: All metrics inferior to DOOD pattern

### Known Issues Avoided

This architecture specifically avoids documented issues:

1. **DNS instability with `host.k3d.internal`** ([k3d#1221](https://github.com/k3d-io/k3d/issues/1221))
   - DNS mapping breaks after system sleep/reboot
   - Gateway IP approach is DNS-independent

2. **`host.docker.internal` unavailable on Linux** ([k3d#1057](https://github.com/k3d-io/k3d/issues/1057))
   - Docker Desktop feature not available in WSL2/native Linux
   - Gateway IP (172.17.0.1) provides equivalent functionality

3. **Registry conflicts with `--network host`** ([k3d#1418](https://github.com/k3d-io/k3d/issues/1418))
   - k3d registry creation incompatible with host networking
   - Separate k3d network avoids this issue

4. **Missing gateway IP in Docker bridge** ([docker/for-linux#981](https://github.com/docker/for-linux/issues/981))
   - Rare occurrence in nested VM scenarios
   - postStart script includes fallback to 172.17.0.1

### Performance Characteristics

**Measured benefits vs alternatives:**

| Operation | Cluster-on-Host (this) | k3d-in-Container | KIND-on-Host |
|-----------|------------------------|------------------|--------------|
| Initial setup | One-time host script | Per-rebuild | One-time host script |
| Devcontainer startup | 2-5s (kubeconfig fix) | 20-30s (cluster create) | 2-5s (kubeconfig fix) |
| Cluster persistence | Yes | No | Yes |
| Memory overhead | Single daemon | Single daemon | Single daemon |
| State preservation | Across rebuilds | Lost on rebuild | Across rebuilds |

---

## Implementation Details

### 1. Cluster on Host

The k3d cluster runs on the host machine, not inside the devcontainer.

**Setup:** [scripts/host/setup-k8s-linux.sh](../scripts/host/setup-k8s-linux.sh)

**Cluster creation:**
```bash
k3d cluster create mariner-dev \
  --registry-use "k3d-mariner-registry:5005" \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --k3s-arg "--tls-san=172.17.0.1@server:0" \
  --k3s-arg "--tls-san=host.docker.internal@server:0" \
  --wait
```

**Benefits:**
- Single Docker daemon (host's) reduces resource overhead
- Cluster persists across devcontainer rebuilds
- No Docker-in-Docker complexity or privileged mode requirements
- Better performance and stability

### 2. Network Separation

k3d creates a dedicated Docker bridge network, isolated from the default bridge where the devcontainer runs:

- **k3d network**: `172.18.0.0/16` (k3d-mariner-dev) - Isolated network for k3d components
- **Default bridge**: `172.17.0.0/16` (docker0) - Standard Docker network for containers

**Network isolation benefits:**
- k3d internals isolated from devcontainer
- Clean network boundaries
- Prevents IP conflicts
- Standard Docker networking patterns

### 3. API Access via Docker Bridge Gateway

The devcontainer accesses the k3d Kubernetes API through Docker's bridge gateway.

**Flow:**
1. k3d exposes the API on all host interfaces: `0.0.0.0:37621` (random port)
2. Docker port forwarding makes this available to all containers via the host
3. DevContainer connects via the Docker bridge gateway: `172.17.0.1:37621`

**Gateway IP on Linux:**
- Default Docker bridge gateway is typically `172.17.0.1`
- Equivalent to `host.docker.internal` on Docker Desktop (Mac/Windows)
- On Linux/WSL2, `host.docker.internal` is not available, so gateway IP is used directly

**Detection at runtime:**
```bash
# In postStart.sh
DOCKER_HOST_IP=$(ip route show | grep default | awk '{print $3}')
```

### 4. TLS Certificate Configuration

For kubectl to connect successfully, the k3s server certificate must include the gateway IP in its Subject Alternative Names (SANs).

**Configuration:** `--k3s-arg "--tls-san=172.17.0.1@server:0"`

**Without this SAN, kubectl rejects the certificate:**
```
x509: certificate is valid for 0.0.0.0, 127.0.0.1, 172.18.0.3, not 172.17.0.1
```

**SANs included:**
- `172.17.0.1` - Docker bridge gateway (required for devcontainer access)
- `host.docker.internal` - Docker Desktop compatibility (Mac/Windows)
- `0.0.0.0` - Default k3d binding
- `127.0.0.1` - Localhost access

### 5. Automatic kubeconfig Fixup

k3d creates kubeconfig with `server: https://0.0.0.0:<port>`, which is not accessible from containers. The postStart hook automatically corrects this.

**Implementation:** [scripts/devcontainer/postStart.sh](../scripts/devcontainer/postStart.sh#L28-L34)

```bash
if [ -f ~/.kube/config ] && grep -q "server: https://0.0.0.0:" ~/.kube/config; then
  DOCKER_HOST_IP=$(ip route show | grep default | awk '{print $3}')
  sed -i "s|server: https://0.0.0.0:|server: https://$DOCKER_HOST_IP:|g" ~/.kube/config
fi
```

**Process:**
1. Detect if kubeconfig contains `server: https://0.0.0.0:<port>`
2. Get Docker gateway IP from default route
3. Replace `0.0.0.0` with gateway IP (typically `172.17.0.1`)

**Execution:** Automatic on devcontainer start, no manual intervention required

---

## Configuration Components

### Docker-outside-of-Docker (DOOD)

**Configuration:** [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json#L42-L44)

```json
{
  "features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {
      "moby": false
    }
  },
  "mounts": [
    "source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind"
  ]
}
```

**Capabilities provided:**
- Access to host's Docker daemon
- Build images on host (shared Docker cache)
- Push to local k3d registry
- Inspect k3d containers
- Use host's Docker network stack

### kubeconfig Mounting

**Configuration:** [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json#L19)

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.kube,target=/home/vscode/.kube,type=bind,consistency=cached"
  ]
}
```

**Effect:** kubectl inside devcontainer uses the same configuration created by k3d on the host

### Port Mappings

Services in the k3d cluster are exposed to the host and devcontainer via port forwards:

| Service | k3d Internal Port | Host Port | Devcontainer Access | Protocol |
|---------|------------------|-----------|---------------------|----------|
| Kubernetes API | 6443 | 37621* | `172.17.0.1:37621` | HTTPS |
| HTTP (Traefik) | 80 | 8080 | `localhost:8080` | HTTP |
| HTTPS (Traefik) | 443 | 8443 | `localhost:8443` | HTTPS |
| Registry | 5000 | 5005 | `localhost:5005` | HTTP |

*Random port assigned by k3d at cluster creation time

**DevContainer port forwarding:** [.devcontainer/devcontainer.json](../.devcontainer/devcontainer.json#L28)

```json
{
  "forwardPorts": [6080, 5173, 8080, 10350]
}
```

---

## Networking Flow

### kubectl Command Flow

When executing `kubectl get pods` inside the devcontainer:

```
kubectl (devcontainer)
  ↓ reads ~/.kube/config
  ↓ server: https://172.17.0.1:37621
  ↓
Docker Bridge Gateway (172.17.0.1)
  ↓ routes to host network stack
  ↓
Host Port 37621
  ↓ forwarded by k3d-proxy container
  ↓
k3d-proxy (172.18.0.2:6443)
  ↓ proxies to k3s-server
  ↓
k3s-server (172.18.0.3:6443)
  ↓ validates TLS certificate (172.17.0.1 in SANs ✓)
  ↓ processes API request
  ↓ returns response
```

### Registry Push Flow

When pushing images from devcontainer:

```
docker push localhost:5005/image
  ↓ devcontainer docker CLI
  ↓ connects to /var/run/docker.sock (host daemon)
  ↓
Host Docker Daemon
  ↓ pushes to localhost:5005
  ↓
k3d Registry Container (port 5005)
  ↓ stores image
  ↓
k3s pulls from k3d-mariner-registry:5005
  ↓ (registry accessible via k3d network DNS)
```

---

## Troubleshooting

### Cannot connect to cluster

**Symptom:** `Unable to connect to the server: dial tcp: connect: connection refused`

**Diagnostic steps:**
```bash
# 1. Verify cluster is running (on host)
k3d cluster list

# 2. Check cluster status
k3d cluster list | grep mariner-dev
# Expected: mariner-dev   1/1   ...   running

# 3. Start cluster if stopped
k3d cluster start mariner-dev

# 4. Verify kubeconfig server address
grep "server:" ~/.kube/config
# Expected: https://172.17.0.1:<port>
# Incorrect: https://0.0.0.0:<port>

# 5. Test API connectivity
curl -k https://172.17.0.1:$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}' | grep -oP '\d+$')/livez
```

**Resolution:**
- If cluster stopped: `k3d cluster start mariner-dev`
- If kubeconfig wrong: Restart devcontainer to trigger postStart.sh

### TLS certificate error

**Symptom:** `x509: certificate is valid for 0.0.0.0, 127.0.0.1, 172.18.0.3, not 172.17.0.1`

**Cause:** Cluster was created without TLS SAN for gateway IP

**Diagnostic:**
```bash
# Check certificate SANs
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d | openssl x509 -text | grep -A1 "Subject Alternative Name"
```

**Resolution:**
```bash
# On host machine
k3d cluster delete mariner-dev
./scripts/host/setup-k8s-linux.sh  # or setup-k8s-macos.sh
```

**Prevention:** Always use setup scripts to create cluster with correct TLS configuration

### Wrong kubeconfig server address

**Symptom:** kubeconfig contains `server: https://0.0.0.0:<port>`

**Cause:** postStart.sh did not execute or failed

**Diagnostic:**
```bash
# 1. Check current kubeconfig
cat ~/.kube/config | grep server

# 2. Check if postStart.sh exists and is executable
ls -la /workspaces/*/scripts/devcontainer/postStart.sh

# 3. Check devcontainer logs for errors
# (View VS Code "Dev Containers" output panel)
```

**Resolution:**
```bash
# Manual fix
DOCKER_HOST_IP=$(ip route show | grep default | awk '{print $3}')
sed -i "s|server: https://0.0.0.0:|server: https://$DOCKER_HOST_IP:|g" ~/.kube/config

# Or restart devcontainer to trigger postStart.sh
```

### Gateway IP not detected

**Symptom:** `DOCKER_HOST_IP` is empty or incorrect

**Diagnostic:**
```bash
# Check default route
ip route show | grep default

# Check bridge interface
ip addr show docker0

# Expected output includes:
# default via 172.17.0.1 dev eth0
```

**Cause:** Missing Docker bridge gateway (rare, occurs in nested VM scenarios)

**Resolution:**
```bash
# Restart Docker daemon (on host)
sudo systemctl restart docker

# Or use hardcoded fallback
sed -i "s|server: https://0.0.0.0:|server: https://172.17.0.1:|g" ~/.kube/config
```

### Port conflicts

**Symptom:** Cluster creation fails with port binding errors

**Diagnostic:**
```bash
# Check which process is using the port
sudo lsof -i :8080  # or :8443, :5005, etc.
```

**Resolution:**
- Stop conflicting service
- Or modify ports in setup script before cluster creation:
  ```bash
  --port "8081:80@loadbalancer" \
  --port "8444:443@loadbalancer"
  ```

---

## References

### Documentation
- [k3d Documentation](https://k3d.io/)
- [k3d Networking](https://k3d.io/v5.4.6/design/networking/)
- [k3s TLS Configuration](https://docs.k3s.io/advanced)
- [Docker Bridge Networking](https://docs.docker.com/network/drivers/bridge/)
- [DevContainers Docker-outside-of-Docker](https://github.com/devcontainers/features/tree/main/src/docker-outside-of-docker)
- [Tilt: Choosing a Local Dev Cluster](https://docs.tilt.dev/choosing_clusters.html)

### Comparative Analysis
- [Garden.io: Remote Dev with Codespaces](https://garden.io/blog/remote-dev-codespaces)
- [KiND vs K3d vs K0s: Best Kubernetes Dev Tool for 2025](https://sanj.dev/post/kind-vs-k3d-vs-k0s)
- [Single-Node Kubernetes Showdown](https://oilbeater.com/en/2024/02/22/minikube-vs-kind-vs-k3d/)

### Known Issues
- [k3d#1057 - host.docker.internal on Linux](https://github.com/k3d-io/k3d/issues/1057)
- [k3d#1221 - host.k3d.internal breaks on reboot](https://github.com/k3d-io/k3d/issues/1221)
- [k3d#1418 - Registry + --network host conflict](https://github.com/k3d-io/k3d/issues/1418)
- [k3d#858 - WSL2 DNS and networking issues](https://github.com/k3d-io/k3d/issues/858)
- [docker/for-linux#981 - Missing gateway IP](https://github.com/docker/for-linux/issues/981)
- [k3s#2365 - TLS SAN configuration](https://github.com/k3s-io/k3s/issues/2365)

### Implementation Examples
- [carlsverre/devcontainer-k3d-tilt-go](https://github.com/carlsverre/devcontainer-k3d-tilt-go) - k3d-in-container pattern
- [rio/features - k3d DevContainer Feature](https://github.com/rio/features) - Automated k3d setup
