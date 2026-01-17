# Mariner

Monorepo for the Mariner web app (Vite + React + MUI) and API (Kotlin + Ktor) backed by Postgres, with a Kubernetes-native development workflow.

## Quick Start

See [docs/setup/quickstart.md](docs/setup/quickstart.md) for the fastest path to a running development environment.

**TL;DR:**
1. Run the host setup script (one-time):
   - WSL2/Linux: `./scripts/host/setup-k8s-linux.sh`
   - macOS: `./scripts/host/setup-k8s-macos.sh`
2. Open in VS Code/Cursor → Reopen in Container
3. Run `tilt up`

## Documentation

See [docs/](docs/) for comprehensive documentation:
- [Setup](docs/setup/quickstart.md) - Getting started guide
- [Development](docs/development/kubernetes.md) - Kubernetes development workflow
- [Architecture](docs/architecture/networking.md) - Networking and design decisions

## Canonical docs

- Product + UX + system narrative: `ANCHOR.md`
- Planning (epics/stories/tasks): `WORK.md` (lightweight backlog for now)
- Long-lived working rules: `DIRECTIVES.md`
- Planning conventions: `work/AGILE.md`
- Agent collaboration conventions: `AGENTS.md`
- Active work tracking: `wip-*.md` (root-level for agent visibility)

## Development environment

The development environment uses:
- **k3d** - Lightweight Kubernetes cluster running on your host
- **Tilt** - Orchestrates builds, deployments, and live updates
- **DevContainer** - Portable development tooling with Docker-outside-of-Docker

### Prerequisites

Run the appropriate host setup script **before** opening the devcontainer:

**WSL2 / Linux:**
```bash
./scripts/host/setup-k8s-linux.sh
```

**macOS:**
```bash
./scripts/host/setup-k8s-macos.sh
```

These scripts handle everything: Docker, kubectl, k3d, and cluster creation.

### Starting Development

1. Open the repo in VS Code or Cursor
2. Click "Reopen in Container" when prompted
3. Run `tilt up` in the terminal
4. Press **space** to open the Tilt UI

### Accessing Services

Once `tilt up` is running:

- **Web (Frontend)**: http://localhost:5173
- **API (Backend)**: http://localhost:8080/health
- **Browser (noVNC)**: http://localhost:6080
- **Tilt UI**: http://localhost:10350
- **PostgreSQL**: localhost:5432 (user: `mariner`, password: `mariner`)

### Git authentication (SSH + `ssh-agent`)

This repo assumes **Git over SSH**. The Dev Containers extension forwards your host `ssh-agent` socket into the container.

Requirements (on your host OS):
- SSH access configured with your Git provider (SSH public key added)
- Host `ssh-agent` running with key loaded: `ssh-add -l`
- Repo origin set to SSH: `git remote set-url origin git@github.com:<namespace>/<repo>.git`

## DevContainer configuration

- Built on `mcr.microsoft.com/devcontainers/base:debian` with devcontainer features
- Features: Node.js 20, Java 21, Docker-outside-of-Docker, kubectl, helm, GitHub CLI
- Tilt installed directly in Dockerfile (third-party features can be unreliable)
- Runs as user `vscode` with zsh and oh-my-zsh pre-configured
- Host's `~/.kube` directory mounted for Kubernetes access
- Docker socket mounted for Docker CLI access

### Persistence

Named Docker volumes preserve data across rebuilds:
- `claude-code-config` → `/home/vscode/.claude`
- `claude-code-bashhistory` → `/commandhistory`
- `gradle_cache` → `/home/vscode/.gradle`

To reset: `docker volume rm claude-code-config claude-code-bashhistory gradle_cache`

### Firewall (optional)

The devcontainer includes an optional iptables-based firewall:
- `./scripts/firewall.sh strict` - Block all except allowed domains
- `./scripts/firewall.sh permissive` - Allow all with rules active
- `./scripts/firewall.sh disable` - Disable completely (default)

## API development (Gradle)

The API uses the Gradle wrapper in `api/gradlew`.

From the repo root (in the devcontainer):
- Build: `./api/gradlew -p api build`
- Test: `./api/gradlew -p api test`
- Run locally: `./api/gradlew -p api run`

## Browser automation

The `browser` service runs Playwright MCP with a virtual display:
- noVNC UI: http://localhost:6080/vnc.html
- MCP endpoint: `http://browser:7331/mcp` (from within the cluster)

Claude Code is pre-configured to use the Playwright MCP server for browser automation.

## Platform Setup by OS

### Windows (WSL2)

1. Install VS Code/Cursor with Dev Containers and WSL extensions
2. Initialize WSL with Ubuntu: `wsl --install -d Ubuntu`
3. Configure Git: `git config --global user.name "Your Name"` and `git config --global user.email "you@example.com"`
4. Clone the repo into WSL (e.g., `~/code/`)
5. Run `./scripts/host/setup-k8s-linux.sh`
6. Open in VS Code from WSL → Reopen in Container

### Linux

1. Install VS Code/Cursor with the Dev Containers extension
2. Clone the repo
3. Run `./scripts/host/setup-k8s-linux.sh`
4. Open in VS Code → Reopen in Container

### macOS

1. Install VS Code/Cursor with the Dev Containers extension
2. Clone the repo
3. Run `./scripts/host/setup-k8s-macos.sh` (installs Colima, Docker, k3d)
4. Open in VS Code → Reopen in Container

## Getting started

- Start in `ANCHOR.md`
- Track work in `WORK.md`
