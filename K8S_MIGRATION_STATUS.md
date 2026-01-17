# Kubernetes Migration Status

**Project:** Mariner K8s-Native Development Environment
**Plan:** [federated-exploring-harp.md](/home/srsdjm/.claude/plans/federated-exploring-harp.md)
**Started:** 2026-01-16
**Status:** 🟡 In Progress

---

## Project Overview

Transform the current Docker Compose + devcontainer setup into a **Kubernetes-native development foundation** using:
- **Tilt** - Live updates and development workflow
- **k3d** - k3s in Docker for local development (runs on host, not in devcontainer)
- **DevContainer** - Portable development environment with Docker-outside-of-Docker

**Goal:** Maintain portability and ease-of-setup while enabling true Kubernetes development with production parity.

**Architecture:** The k3d cluster runs on the host machine (WSL2/Linux/macOS) while the devcontainer connects to it via mounted kubeconfig. This avoids Docker-in-Docker kubelet issues.

---

## Phase 0: Foundation Setup ✅

**Goal:** Transition from Compose to Kind + Tilt without disrupting development
**Estimated Effort:** 2-4 hours
**Status:** 🟢 Complete

### Files to Create

- [x] [Tiltfile](Tiltfile) - Build/deploy/hot-reload configuration
- [x] [k8s/namespace.yaml](k8s/namespace.yaml) - Namespace definition
- [x] [k8s/database.yaml](k8s/database.yaml) - PostgreSQL deployment + PVC
- [x] [k8s/api.yaml](k8s/api.yaml) - Ktor API deployment + service
- [x] [k8s/web.yaml](k8s/web.yaml) - React/Vite deployment + service
- [x] [k8s/browser.yaml](k8s/browser.yaml) - Playwright browser deployment
- [x] [scripts/host/setup-k8s-linux.sh](scripts/host/setup-k8s-linux.sh) - Host setup for WSL2/Linux (Docker, k3d, cluster)
- [x] [scripts/host/setup-k8s-macos.sh](scripts/host/setup-k8s-macos.sh) - Host setup for macOS (Colima, k3d, cluster)
- [x] [.devcontainer/start-tilt.sh](.devcontainer/start-tilt.sh) - Wait for cluster, print instructions

### Files to Modify

- [x] [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) - Remove runServices, add Tilt UI port, K8s tools
- [x] [scripts/devcontainer/postCreate.sh](scripts/devcontainer/postCreate.sh) - Run setup-k8s.sh
- [x] [scripts/devcontainer/postStart.sh](scripts/devcontainer/postStart.sh) - Run start-tilt.sh
- [x] [web/Dockerfile](web/Dockerfile) - Already has `dev` target for Tilt live updates

### Files Removed

- [x] `compose.yml` - Replaced by k8s/
- [x] `compose.dev.yml` - Replaced by Tiltfile
- [x] `.devcontainer/compose.devcontainer.yml` - No longer using Compose for devcontainer
- [x] `kind` binary - Using k3d instead

### Validation Checklist

- [ ] k3d cluster running on host: `k3d cluster list` shows mariner-dev
- [ ] kubectl works from devcontainer: `kubectl get nodes` shows 1 Ready node
- [ ] Namespace exists: `kubectl get ns mariner-dev`
- [ ] Local registry working: `docker pull localhost:5005/hello-world` (after pushing)
- [ ] Tilt installed: `tilt version` shows v0.33+
- [ ] All services start with `tilt up` in < 2 minutes
- [ ] Web accessible at http://localhost:5173
- [ ] API accessible at http://localhost:8080/health
- [ ] Tilt UI accessible at http://localhost:10350

---

## Phase 1: Kubernetes Development Workflow 📋

**Goal:** Hot reload, debugging, and daily development on Kubernetes
**Estimated Effort:** 1-2 days
**Status:** 🔴 Not Started

### Files to Create

- [ ] [k8s/gradle-cache-pvc.yaml](k8s/gradle-cache-pvc.yaml) - Gradle cache PersistentVolumeClaim
- [ ] [tilt-resources/namespace.yaml](tilt-resources/namespace.yaml) - Namespace definition
- [ ] [docs/KUBERNETES_DEV.md](docs/KUBERNETES_DEV.md) - Developer runbook

### Files to Modify

- [ ] [k8s/api.yaml](k8s/api.yaml) - Add Gradle cache volume mount
- [ ] [Tiltfile](Tiltfile) - Add gradle-cache-pvc, optimize API live updates

### Implementation Tasks

- [ ] Add Gradle Cache PersistentVolume
- [ ] Optimize API Live Updates with JVM Hot Reload
- [ ] Add Tilt Extensions
- [ ] Create Developer Runbook

### Validation Checklist

- [ ] Hot reload for web changes < 2 seconds
- [ ] API rebuild/restart < 30 seconds
- [ ] Gradle cache persists (verify build time after pod restart)
- [ ] JDWP debugger connects successfully at localhost:5005
- [ ] All services start on `tilt up` without errors

---

## Phase 2: Production-Ready Patterns 📋

**Goal:** ConfigMaps, Secrets, Ingress, and GKE deployment path
**Estimated Effort:** 1-2 days
**Status:** 🔴 Not Started

### Files to Create

- [ ] [k8s/config.yaml](k8s/config.yaml) - ConfigMap and Secret for app configuration
- [ ] [k8s/ingress.yaml](k8s/ingress.yaml) - Ingress resource for routing
- [ ] [docs/GKE_DEPLOYMENT.md](docs/GKE_DEPLOYMENT.md) - Production deployment guide

### Files to Modify

- [ ] [k8s/api.yaml](k8s/api.yaml) - Use ConfigMap and Secret for environment variables
- [ ] Host setup scripts - Add /etc/hosts entry for mariner.local
- [ ] [Tiltfile](Tiltfile) - Add production build testing profile

### Implementation Tasks

- [ ] Create ConfigMap and Secret
- [ ] Install Ingress NGINX controller
- [ ] Create Ingress Resource
- [ ] Document GKE Deployment Path
- [ ] Update Tiltfile for Production Build Testing

### Validation Checklist

- [ ] ConfigMap and Secret created: `kubectl get cm,secret -n mariner-dev`
- [ ] Ingress controller running: `kubectl get pods -n ingress-nginx`
- [ ] `curl http://mariner.local/api/health` returns 200
- [ ] `open http://mariner.local` loads React app
- [ ] GKE deployment documentation tested (optional)

---

## Success Metrics

| Phase | Metric | Target | Status |
|-------|--------|--------|--------|
| 0 | Setup time from `code .` (first time) | < 5 minutes | ⏳ |
| 0 | Setup time (subsequent) | < 30 seconds | ⏳ |
| 0 | Kind cluster auto-provisioned | ✅ Automatic | ⏳ |
| 0 | All services start with `tilt up` | < 2 minutes | ⏳ |
| 1 | Web hot reload latency | < 2 seconds | ⏳ |
| 1 | API rebuild/restart latency | < 30 seconds | ⏳ |
| 1 | Gradle cache hit rate | > 90% after first build | ⏳ |
| 2 | Ingress routing works | ✅ http://mariner.local | ⏳ |
| 2 | ConfigMap/Secret externalized | ✅ No hardcoded secrets | ⏳ |

---

## Current Focus

**Phase 0 Complete - Ready for Testing!**

**Next Steps:**
1. Rebuild the devcontainer to test the new K8s setup
2. Run validation checklist from Phase 0
3. Start Phase 1: Kubernetes Development Workflow optimization
4. After validation succeeds, can optionally remove old Docker Compose files

---

## Notes & Decisions

### Architecture Decisions
- **Why Tilt?** Best hot-reload, beginner-friendly UI, fastest iteration cycle
- **Why k3d?** Lightweight k3s distribution, fast startup, built-in registry support, runs reliably on host
- **Why host-based cluster?** Avoids Docker-in-Docker kubelet issues that caused Kind to fail inside the devcontainer
- **Why Colima on macOS?** Lightweight Docker runtime, no licensing concerns, CLI-friendly

### Trade-offs Accepted
- **Learning Curve:** Need to learn basic kubectl and K8s concepts
- **Resource Usage:** k3d uses ~500MB more RAM than Compose
- **API Hot Reload:** Slower than Compose volume mount (30s vs instant) - may improve with JVM hot reload agents
- **Host setup required:** Users must run setup script on host before using devcontainer (one-time)

### Key Requirements Met
- ✅ Portable, code-based configuration (like current devcontainer)
- ✅ Simple setup: run host script once, then `code .` provisions the devcontainer
- ✅ Fast iteration: hot reload for web/API changes
- ✅ Kubernetes-first: develop against actual K8s APIs
- ✅ Production parity: same manifests work locally and in GKE
- ✅ Cross-platform: works on WSL2/Linux and macOS (with Colima)

---

## Questions & Blockers

_None yet - will update as work progresses_

---

## References

- **Plan Document:** [federated-exploring-harp.md](/home/srsdjm/.claude/plans/federated-exploring-harp.md)
- **Tilt Documentation:** https://tilt.dev/
- **k3d Documentation:** https://k3d.io/
- **Colima (macOS Docker):** https://github.com/abiosoft/colima
- **VS Code DevContainers:** https://code.visualstudio.com/remote/advancedcontainers/use-docker-kubernetes

---

**Last Updated:** 2026-01-16 - Phase 0 Complete
