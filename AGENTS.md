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

- Add setup steps and common build/test commands once the stack is chosen.
- Automated tests exist for `api` (run `./api/gradlew -p api test`); `web` tests are not set up yet.
- Container runtime is Docker; use `docker compose` for Dev Container services and do not assume Podman is installed.

### Runtime stack (local + test/prod parity)

- `compose.yml` is the source of truth for runtime containers (db, api, web).
- `compose.dev.yml` is for dev-only port mappings and debug hooks; avoid changing runtime behavior there.
- `.devcontainer/compose.devcontainer.yml` defines the `dev` tooling container; do not add runtime services to it.
- The Dev Container uses docker-compose to orchestrate all services: `dev`, `db`, `api`, `web`, and `browser`.
- All services start when the Dev Container runs, ensuring the full stack is available by default.
- The dev container depends on `db` and `api` health checks before finishing startup.
- The web client runs Vite in dev and is served by Nginx in the runtime image.

### Dependency lifecycle

- Keep the Playwright image tag and Playwright MCP pin aligned; update both together.

### Environment notes (dev container)

- The dev container is built on Node 20 with Claude Code CLI, Java 21, PostgreSQL client, and Docker-outside-of-Docker support.
- Runs as user `node` with zsh as the default shell (workspace at `/workspace`).
- `docker` CLI is available inside the dev container; you can inspect services with `docker compose` from within the container.
- Network socket operations are restricted in the default sandbox, so connectivity checks may require escalated execution.
- Use `DATABASE_SERVICE_URL` for in-stack access and `DATABASE_HOST_URL` for host tooling; avoid mixing them.
- Vite allows the `web` host to enable `http://web:5173` access from the Dev Container.
- For Git auth in automated/agent contexts, prefer SSH remotes via a forwarded `ssh-agent` when available. Avoid copying private keys into containers; treat any tokens as secrets (don't commit them; avoid persisting them in plaintext).
- Claude Code is pre-configured with Playwright MCP for browser automation at `http://browser:7331/mcp`.

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
