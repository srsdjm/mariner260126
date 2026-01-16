# Mariner

Monorepo for the Mariner web app (Vite + React + MUI) and API (Kotlin + Ktor) backed by Postgres, with a Dev Container-first workflow.

## Canonical docs

- Product + UX + system narrative: `ANCHOR.md`
- Planning (epics/stories/tasks): `WORK.md` (lightweight backlog for now)
- Long-lived working rules: `DIRECTIVES.md`
- Planning conventions: `work/AGILE.md`
- Agent collaboration conventions: `work/AGENTIC.md`

## Development environment (required)

- Use the Dev Container as the canonical Linux development environment (Windows/macOS/Linux).
- This ensures parity with the deployed Linux environment and avoids host-specific drift.
- The runtime stack is defined in `compose.yml` and runs as separate containers; the Dev Container provides tooling only.

### Git authentication (SSH + `ssh-agent`)

This repo assumes **Git over SSH**. When you open the repo in the Dev Container, the Dev Containers extension will **forward your host `ssh-agent` socket into the container if an agent is running**, so Git-over-SSH works inside the container without copying private keys into it.

Cursor agent sandbox note (terminal commands run by the AI):

- Shell commands executed by the AI may run in a **sandboxed command runner** that can report `uid=0(root)` even though it is **not your host/root account**. Treat this as “pseudo-root inside the sandbox,” not real system root.
- The sandbox also constrains filesystem access: it is typically limited to the workspace for writes and may not expose your full home-directory credential setup. As a result, host/user SSH files (for example `~/.ssh/known_hosts`, `~/.ssh/config`, or access to your interactive agent session) may be missing or inaccessible to AI-run commands even when they work fine in your terminal.
- If an AI-run command fails with SSH errors like “host key verification failed” but `ssh -T git@gitlab.com` and `git push` work in your terminal, run the Git/SSH operation **from your terminal / Dev Container terminal** (your real user context), not via the AI command runner.

Requirements (on your host OS):

- Ensure you’ve set up SSH access with GitLab (your SSH public key is added to GitLab).
- Ensure your host `ssh-agent` is running and has your key loaded:
  - `ssh-add -l` (should list at least one key; run `ssh-add ~/.ssh/<key>` if needed)
- Set the repo `origin` to SSH (GitLab example):
  - `git remote set-url origin git@gitlab.com:<namespace>/<repo>.git`

Verify (inside the Dev Container):

- `ssh-add -l` should work (exit 0 = keys loaded, exit 1 = agent reachable but no keys, exit 2 = agent not reachable).

One-time SSH host key setup (prevents non-interactive push failures):

- SSH will refuse to connect until `gitlab.com` is recorded in `~/.ssh/known_hosts` for the user doing the push.
- Before your first `git push` over SSH, run an interactive SSH command once so you can review/accept the host key:
  - On your host: `ssh -T git@gitlab.com`
  - If you push from inside the Dev Container: run the same command inside the container too (it has its own `~/.ssh/known_hosts`).

Agent forwarding note:

- **`ForwardAgent` is intentionally not enabled by default inside the Dev Container** (your host `~/.ssh/config` does not automatically apply in the container).
- The Dev Container is primarily for **local development against the Compose stack**. If you’re SSHing to hosts outside the stack, you probably should do it **from the host**.
- If you still need it from inside the container (rare), prefer `ssh -A <host>` per connection. Only set `ForwardAgent yes` in the container’s `~/.ssh/config` if you understand the risk and have a clear need.

### Host shell: auto-start `ssh-agent` (recommended)

Configure your host shell to auto-start `ssh-agent` on login and reuse the agent across terminals.

Add this to `~/.profile` (login shells):

```bash
# --- ssh-agent bootstrap (auto-start on login) ---
# Starts (or reuses) a single ssh-agent per login session and stores its
# environment in $HOME/.ssh/agent.env for reuse by new shells.
SSH_ENV="$HOME/.ssh/agent.env"

ssh_agent_ok() {
  ssh-add -l >/dev/null 2>&1
  case $? in
    0|1) return 0 ;; # agent reachable (0=has keys, 1=no keys)
    *)   return 1 ;;
  esac
}

start_ssh_agent() {
  if [ -n "${SSH_AUTH_SOCK:-}" ] && ssh_agent_ok; then
    return 0
  fi

  if [ -f "$SSH_ENV" ]; then
    . "$SSH_ENV" >/dev/null 2>&1
    if [ -n "${SSH_AUTH_SOCK:-}" ] && ssh_agent_ok; then
      return 0
    fi
  fi

  eval "$(ssh-agent -s)" >/dev/null
  umask 077
  {
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID"
  } > "$SSH_ENV"
}

start_ssh_agent
```

And this to `~/.bashrc` (interactive shells), so new terminals reuse the same agent:

```bash
if [ -f "$HOME/.ssh/agent.env" ]; then
  . "$HOME/.ssh/agent.env" >/dev/null 2>&1
fi
```

To enable agent forwarding, add to `~/.ssh/config`:

```sshconfig
Host *
  ForwardAgent yes
```

Verify:

```bash
echo "$SSH_AUTH_SOCK"
ssh-add -l   # exit 1 is OK (agent running but no keys loaded)
```

Getting started:

- Install Docker Engine + Docker Compose plugin, and VS Code or Cursor.
- Install the Dev Containers extension (`ms-vscode-remote.remote-containers` or `anysphere.remote-containers`).
- Copy `.env.example` to `.env` and adjust values if needed (defaults work for local development).
- Open the repo in the Dev Container (`.devcontainer/devcontainer.json`).
- The Dev Container starts the full stack (db, api, web, browser) by default; stop services with `docker compose ... down` if you only want tooling.
- The Dev Container uses `shutdownAction: stopCompose` so stopping/rebuilding it shuts down the Compose stack.

Dev Container configuration:

- Built on Node 20 with Claude Code CLI, Java 21, PostgreSQL client, and Docker-outside-of-Docker support.
- Runs as user `node` with zsh as the default shell.
- The dev service is defined in `.devcontainer/compose.devcontainer.yml` and integrates with the runtime stack via docker-compose.
- Locale is configured for en_US.UTF-8 to avoid warnings from PostgreSQL client and other tools.
- Docker socket permissions are dynamically adjusted at startup to ensure seamless Docker CLI access.

Dev Container firewall (optional):

- The dev container includes an optional iptables-based firewall for network security testing.
- By default, the firewall is **disabled** - all network traffic is allowed for normal development.
- Use [scripts/firewall.sh](scripts/firewall.sh) to control the firewall at runtime:
  - `./scripts/firewall.sh strict` - Block all outbound traffic except explicitly allowed domains (GitHub, npm, Anthropic API, VSCode marketplace)
  - `./scripts/firewall.sh permissive` - Allow all outbound traffic but with firewall rules active
  - `./scripts/firewall.sh disable` - Disable firewall completely (default state)
  - `./scripts/firewall.sh status` - Show current firewall status
- In strict mode, add additional allowed domains to [.devcontainer/init-firewall.sh](.devcontainer/init-firewall.sh)
- Firewall settings do not persist across container restarts - reapply after rebuilding the dev container

Dev Container persistence (Claude Config, Bash History, Gradle cache):

- The Dev Container uses named Docker volumes for `/home/node/.claude`, `/commandhistory`, and `/home/node/.gradle` via `.devcontainer/compose.devcontainer.yml` so Claude configuration, command history, and Gradle caches survive rebuilds.
- The volumes are named with the Compose project prefix (`mariner_claude-code-config`, `mariner_claude-code-bashhistory`, and `mariner_gradle_cache`) via `COMPOSE_PROJECT_NAME` in `.env`.
- To reset, remove the dev container and delete the volumes: `docker volume rm mariner_claude-code-config mariner_claude-code-bashhistory mariner_gradle_cache` (or `docker volume prune` to remove unused volumes).
- For a full Compose + volume reset (db + web + all dev container volumes), run: `scripts/dev/clean-slate.sh`.

## Windows setup (WSL + Dev Container)

1. Ensure Cursor on Windows has the Dev Containers and WSL extensions installed.
2. Initialize or re-initialize WSL with an Ubuntu image.
3. Install base packages in WSL: `sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg lsb-release unzip`
4. Configure Git identity: `git config --global user.name "Your Name"` and `git config --global user.email "you@example.com"`
5. Create a `code` folder in your WSL home directory (for example, `mkdir -p ~/code`).
6. Use the `><` icon in the bottom-left of Cursor to "Connect to WSL".
7. Clone the repo into `~/code`.
8. Open the repository folder in Cursor (from the WSL window).
9. Follow the Dev Container prompts to install/configure Docker and connect.

## Linux setup

- Install Docker Engine + Docker Compose plugin.
- Install VS Code or Cursor and the Dev Containers extension (`ms-vscode-remote.remote-containers` or `anysphere.remote-containers`).
- Clone the repo, copy `.env.example` to `.env` (defaults work for local development).
- Open the repo in the Dev Container when prompted; it will start the Compose stack (db/api/web/browser) automatically.
- Wait for the devcontainer to complete startup (healthchecks can take up to 120s).
- Verify services with `docker compose -f compose.yml -f compose.dev.yml ps`.

## macOS setup

- Install Docker Desktop (includes Docker Compose).
- Install VS Code or Cursor and the Dev Containers extension.
- Clone the repo, copy `.env.example` to `.env` (defaults work for local development).
- Open the repo in the Dev Container; allow Docker Desktop permissions (Rosetta may be required for amd64 images on Apple Silicon).
- Wait for the devcontainer to complete startup (healthchecks can take up to 120s).
- Verify services with `docker compose -f compose.yml -f compose.dev.yml ps`.

## Runtime stack (Docker Compose)

The runtime stack mirrors test/prod behavior and is defined in `compose.yml`. Development-only port mappings and debug hooks live in `compose.dev.yml`.

Environment variables:

- `.env` holds local defaults; `.env.example` is the template committed to the repo.
- `COMPOSE_PROJECT_NAME` pins the Compose project name so the Dev Container and scripts manage the same containers (override it if you run multiple checkouts in parallel).
- The web app uses relative `/api` requests; Vite proxies `/api` to `http://api:8080` in dev and Nginx proxies `/api` to the API in the runtime image.
- `DATABASE_SERVICE_URL` defines the API's database connection string on the Compose network (set as `DATABASE_SERVICE_URL` in Compose).
- `DB_HOST_PORT` controls the dev database port published on the host (defaults to `5432`).
- `DATABASE_HOST_URL` is for host tools (psql/DBeaver) connecting to the dev database on `localhost:${DB_HOST_PORT}` (keep the port in sync if you change it).
- `PII_ENCRYPTION_KEY` is a Base64-encoded 256-bit key used to encrypt SSNs at rest in the API.
- `WORKSPACE_HOST_PATH` (optional) points the dev-only Vite bind mount at your host checkout; the Dev Container sets this to `${localWorkspaceFolder}` automatically so hot reload sees edits when `docker compose` runs inside the Dev Container.

Dev-only overrides in `compose.dev.yml`:

- Host port mappings for `db` (`DB_HOST_PORT` → 5432 in-container), `api` debug (5005), and `web` (5173).
- `web` uses the `dev` build target with a bind mount for Vite hot reload (`${WORKSPACE_HOST_PATH:-.}/web:/workspace`). A named volume backs `/workspace/node_modules` so container-installed deps (including `vite`) stay visible when the bind mount would otherwise hide them; this avoids requiring host `node_modules` and prevents permission churn.
- `api` enables JDWP debugging in development.
- `browser` sets `shm_size` to 4gb to avoid Chrome shared-memory crashes in containers.

Common commands:

- Start the database only: `docker compose -f compose.yml -f compose.dev.yml up db`
- Start the full stack: `docker compose -f compose.yml -f compose.dev.yml up --build`
- Check container status: `docker compose -f compose.yml -f compose.dev.yml ps`
- Stop everything: `docker compose -f compose.yml -f compose.dev.yml down`
- Reset the dev stack and volumes: `scripts/dev/clean-slate.sh`
- Dev Container quick loop (runs against host Docker): `scripts/dev/api-up.sh`, `scripts/dev/web-up.sh`, `scripts/dev/api-logs.sh`, `scripts/dev/web-logs.sh`

Dev Container Docker access (why commands work inside the container):

- The Dev Container installs the Docker CLI via the `docker-outside-of-docker` feature.
- The host Docker socket is mounted into the Dev Container at `/var/run/docker.sock`.
- This means `docker compose ...` executed inside the Dev Container controls the host Docker engine that is already running the Compose stack.
- Use this to rebuild/restart only the services you touched (api/web) without rebuilding the Dev Container itself.
- Docker socket permissions are automatically adjusted during container startup to match the host socket GID (handled by `scripts/devcontainer/postStart.sh`).

Debugging notes:

- The API debug port is exposed in `compose.dev.yml` at `5005` (JDWP).
- The web client runs Vite in dev (`http://localhost:5173`) and is served by Nginx in the runtime image.
- Vite allows `localhost`/`127.0.0.1`/`.localhost` for host access, and `web` for in-network access (see `web/vite.config.ts`).
- The runtime Nginx proxy forwards `/api` requests to the `api` service on the Compose network.
- For host-side API calls in development, use the Vite proxy via `http://localhost:5173/api/...`.
- The Vite dev server runs only in development, inside the `web` container; the Dev Container reaches it over the Compose network at `http://web:5173`.
- In production, Vite is not part of the runtime lifecycle; `web/Dockerfile` builds the static bundle in the `build` stage and the final `prod` stage serves it via Nginx, which is what `compose.yml` uses.
- The Vite host allowlist includes `web` so development requests from the Dev Container are accepted.
- The Dev Container runs `scripts/devcontainer/healthcheck.sh` after build/connect to wait for db/api/web and validate basic connectivity.
- The dev-only `browser` service is reachable at `http://localhost:6080/vnc.html` (noVNC) and exposes Playwright MCP over SSE on port `7331`.

## Browser automation (dev-only)

- The `browser` service runs Playwright MCP inside the Compose stack with a virtual display.
- The dev container config uses `ipc: host` and `shm_size: "4gb"` for Chromium stability; tune `compose.dev.yml` if you change memory budgets.
- Playwright MCP loads `browser/mcp.config.json` (copied to `/app/mcp.config.json`) to pass `--disable-dev-shm-usage` for Chromium shared-memory stability.
- Playwright MCP is pinned via `PLAYWRIGHT_MCP_VERSION` (default `0.0.47`) and installed during the `browser` image build; bump the version and run `docker compose build browser` to upgrade.
- Keep the Playwright image tag and MCP dependency aligned (Playwright best practice); update them together when bumping versions.
- Use noVNC to view the headed browser at `http://localhost:6080/vnc.html`.

Playwright MCP configuration:

- The Playwright MCP server runs with HTTP transport on port `7331` at `http://browser:7331/mcp` (accessible within the compose network).
- Claude Code in the dev container is pre-configured to use this MCP server for browser automation capabilities.
- To manually configure other MCP clients: `claude mcp add --transport http playwright http://browser:7331/mcp`
- Verify the connection: `claude mcp list` (should show playwright as connected when inside the dev container).
- The MCP server enables Claude Code to perform browser automation tasks: navigate websites, click elements, fill forms, take screenshots, and interact with web applications.

## API development (Gradle)

The API uses the Gradle wrapper in `api/gradlew` so you don't need Gradle installed on your host.

From the repo root (in the Dev Container):

- Build: `./api/gradlew -p api build`
- Run API locally (outside Compose): `./api/gradlew -p api run`
- Build the distribution used by the container image: `./api/gradlew -p api installDist`
- Test: `./api/gradlew -p api test`

### Docker build caching (API)

The API Docker image caches dependency resolution in a separate layer by copying only Gradle wrapper + build files and running `gradle dependencies` before copying `src/`. This speeds up rebuilds when application code changes but the build inputs do not.

Cache invalidates when any of these change:

- `api/build.gradle.kts`
- `api/settings.gradle.kts`
- `api/gradle/`
- `api/gradlew` or `api/gradlew.bat`

Clean build use cases: validating fresh dependency downloads, clearing corrupted caches, or ensuring build-script changes are picked up.

Clean build options:

- `docker compose build --no-cache api` then `docker compose -f compose.yml -f compose.dev.yml up -d api`
- `docker builder prune` (drops all local build cache)

## Getting started

- Start in `ANCHOR.md`.
- Track work in `WORK.md` (split into `work/` artifacts later if/when needed).
