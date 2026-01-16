# Browser Stability Notes (Playwright MCP + Chromium)

## Summary
- `--disable-dev-shm-usage` is a Chromium-only launch arg that forces Chromium to use `/tmp` instead of `/dev/shm`.
- Playwright supports custom browser args via `launchOptions.args`, but warns that custom args can break Playwright behavior.
- Playwright MCP exposes `browser.launchOptions` via config, so the flag can be passed when starting the MCP server with `--config`.
- Playwright Docker guidance recommends `--ipc=host` for Chromium to avoid shared-memory crashes; this is the preferred fix before disabling `/dev/shm`.

## Repo context
- `compose.dev.yml` already sets `ipc: host` and `shm_size: "4gb"` for the `browser` service.
- `browser/mcp.config.json` sets `browser.launchOptions.args = ["--disable-dev-shm-usage"]`.
- `browser/start.sh` launches `npx @playwright/mcp@latest` with `--config /app/mcp.config.json`.
- `browser/Dockerfile` copies `browser/mcp.config.json` into `/app/mcp.config.json`.

## Current configuration
1. The MCP config in `browser/mcp.config.json` enables `--disable-dev-shm-usage`.
2. The container entrypoint reads it from `/app/mcp.config.json`.
3. Compare stability against the `ipc: host` + `shm_size` baseline.

## References
- Playwright BrowserType launch `args` option: https://playwright.dev/docs/api/class-browsertype#browser-type-launch-option-args
- Playwright Docker guidance (`--ipc=host`): https://playwright.dev/docs/docker
- Playwright MCP config schema (launchOptions): https://raw.githubusercontent.com/microsoft/playwright-mcp/main/README.md
