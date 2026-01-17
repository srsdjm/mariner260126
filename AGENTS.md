# AGENTS

This repo follows an ANCHOR-first workflow. `ANCHOR.md` is the canonical narrative definition of the product.

## Elevation checklist

Assume a sandboxed environment. Request escalation up front when a command needs network or host access.

- Call out likely escalation needs in your plan so retries are expected, not surprises.
- If a command fails due to sandboxing, rerun it with escalation and explain why it is needed.
- If you discover a new escalation case, add it here so future agents see it.

Common escalation cases:

- Network socket access (health checks, `curl` to `db`/`api`/`web`, `psql` to `db`).
- Remote git operations (`git push`, `git fetch`, `git pull`).
- Host container tooling (`docker compose ...`) or host reachability/port probes.

## Source of truth

- Maintain `ANCHOR.md` as the source of truth for product intent, UX, and system definition.
- Use `ANCHOR.md` to guide tactical tasks, architecture, and implementation decisions.
- If `ANCHOR.md` is incomplete, inconsistent, or missing key definitions, propose updates before or alongside code changes.

## Planning

- Track epics, stories, and tasks in `WORK.md` (and `work/` when split out).
- Keep planning artifacts lightweight until more structure is required.

## Directives

- Maintain long-lived strategies and directives in `DIRECTIVES.md`.
- Follow `DIRECTIVES.md` when it conflicts with tactical plans; note exceptions explicitly.

## Lifecycle and operations

### Setup and testing

- **First-time setup**: Run the host setup script before opening the devcontainer:
  - WSL2/Linux: `./scripts/host/setup-k8s-linux.sh`
  - macOS: `./scripts/host/setup-k8s-macos.sh`
- **Starting development**: Open the repo in VS Code/Cursor, reopen in container, then run `tilt up`.
- Automated tests exist for `api` (run `./api/gradlew -p api test`); `web` tests are not set up yet.
- Container runtime is Docker; the devcontainer uses Docker-outside-of-Docker to access the host Docker daemon.

### Platform philosophy

- **Target platform**: GKE Autopilot. We avoid platform-specific modifications and stay "middle of the road" on Kubernetes to focus on application architecture and business features rather than infrastructure complexity.
- **Local development**: Use k3d (k3s in Docker) for local Kubernetes. It's lightweight, fast, and sufficient for app development. Differences from upstream K8s don't matter for our use case.
- **Simplify the dev stack**: Continuously look for opportunities to reduce moving parts, dependencies, and configuration. Fewer tools = less to break.

### Runtime stack (Kubernetes)

- **k8s/**: Kubernetes manifests for all services (database, api, web, browser).
- **Tiltfile**: Orchestrates builds, deployments, and live updates for local development.
- The k3d cluster runs on the host machine; the devcontainer connects via mounted kubeconfig.
- Run `tilt up` to start all services; use `tilt down` to stop them.
- The web client runs Vite in dev and is served by Nginx in the production image.

### Dependency lifecycle

- Keep the Playwright image tag and Playwright MCP pin aligned; update both together.

### Environment notes (dev container)

- The devcontainer is built on Debian with Node 20, Java 21, PostgreSQL client, kubectl, Tilt, and Docker-outside-of-Docker support.
- Runs as user `vscode` with zsh as the default shell (workspace at `/workspaces/<repo>`).
- `docker` and `kubectl` CLIs are available inside the devcontainer.
- The host's `~/.kube` directory is mounted for Kubernetes access.
- Network socket operations are restricted in the default sandbox, so connectivity checks may require escalated execution.
- For Git auth in automated/agent contexts, prefer SSH remotes via a forwarded `ssh-agent` when available. Avoid copying private keys into containers; treat any tokens as secrets (don't commit them; avoid persisting them in plaintext).
- Claude Code is pre-configured with Playwright MCP for browser automation at `http://browser:7331/mcp` (when browser pod is running).

## Simplicity first

**Core principle: Complexity is expensive. A less complex solution is a better solution, as long as it meets the requirements.**

Before implementing, always ask:
- What is the simplest approach that solves the actual problem?
- Can this be done with existing tools/patterns instead of adding new ones?
- Am I solving the stated problem, or a hypothetical future problem?

Implementation guidelines:
- **Discuss before building**: When multiple approaches exist, present options and trade-offs to the user before implementing. Let them choose the level of sophistication.
- **Start minimal**: Implement the simplest version that meets stated requirements. Don't add features, abstractions, or flexibility unless explicitly requested.
- **Avoid premature optimization**: Don't add caching, pooling, retry logic, or other complexity unless there's a demonstrated need.
- **Resist abstraction**: Three similar pieces of code are better than one premature abstraction. Wait for the pattern to emerge before extracting.
- **Question dependencies**: Adding a library? Consider if the problem can be solved with standard library features or a few lines of code instead.
- **Delete over comment**: Remove unused code completely. Don't leave commented-out code, `// TODO`, or "for future use" scaffolding.
- **Standard over custom**: Use language/framework idioms and conventions. Custom wrappers and helpers should be rare and well-justified.

Red flags that indicate over-engineering:
- Configuration files for things that could be constants
- Factories, builders, or managers for simple object creation
- Interfaces with a single implementation
- Middleware/plugins/hooks for one-time operations
- Generic solutions when specific requirements are clear
- "Future-proofing" for hypothetical requirements

When you catch yourself building something complex:
1. Stop and describe the simplest possible solution
2. Explain why the simpler approach won't work
3. Let the user decide if the complexity is justified

Remember: **The best code is no code. The second best code is simple code.**

## Documented over guessed

- Prefer documented solutions over guesswork (upstream docs, READMEs, or authoritative references) and record the reference when making a decision.
- If docs are missing or unclear, state assumptions explicitly and add a quick validation step.

## Web browsing (research + exploratory testing)

Web browsing is available via built-in WebFetch/WebSearch tools and Playwright MCP for interactive browser automation.

- Use WebFetch/WebSearch for documentation research, reading articles, and finding solutions.
- Use Playwright MCP (via browser automation tools) for interactive browser tasks: clicking, form filling, screenshots, testing web apps.
- Favor web search + verified public sources over guessing or working around problems.
- Before web searching, state your intent and plan (what you're looking for, where you'll look, and what decisions you expect to make).
- Prefer authoritative sources (official vendor/upstream docs, standards bodies, reputable OSS project docs); note assumptions when you can't verify.
- Record durable insights where they belong so they persist beyond the current thread (typically: `AGENTS.md` for agent workflow, `DIRECTIVES.md` for durable principles, `ANCHOR.md` for product/system definition, `WORK.md`/`work/` for planning artifacts).
- Use browser automation to interact with the app under development (UI flows, configuration verification, exploratory testing) as part of the dev loop.

## Instruction discovery (Cursor)

- Keep this file skimmable; prefer nested `AGENTS.md` files (e.g. under `api/` or `web/`) for subproject-specific rules instead of growing the root file indefinitely.
- Cursor composes instructions from global + project + nested files, with directories closer to the current working directory taking precedence; `AGENTS.override.md` wins over `AGENTS.md` within the same directory.
- Empty instruction files are ignored; extremely large combined instructions may be truncated (split rules into nested files if needed).
- If instructions appear “ignored” or “stale”, verify which instruction files are being loaded and from where (nested overrides win).

## References

- https://agents.md/
