#!/usr/bin/env bash
set -euo pipefail

: "${DISPLAY:=:99}"
: "${MCP_PORT:=7331}"
: "${NOVNC_PORT:=6080}"
: "${SCREEN_RES:=1920x1080x24}"
: "${VNC_PORT:=5900}"
: "${PLAYWRIGHT_MCP_VERSION:=0.0.47}"

display_num="${DISPLAY#:}"
x_lock="/tmp/.X${display_num}-lock"
x_sock="/tmp/.X11-unix/X${display_num}"

mkdir -p /tmp/.X11-unix
# Docker restarts keep /tmp; clear stale X lock/socket files before Xvfb.
rm -f "${x_lock}" "${x_sock}"

fluxbox_config="${HOME}/.fluxbox"
fluxbox_apps="${fluxbox_config}/apps"
fluxbox_overlay="${fluxbox_config}/overlay"
fluxbox_lastwallpaper="${fluxbox_config}/lastwallpaper"
mkdir -p "${fluxbox_config}"

if [ -f "${fluxbox_overlay}" ]; then
  sed -i '/^background:/d' "${fluxbox_overlay}"
  printf '\nbackground: unset\n' >> "${fluxbox_overlay}"
else
  cat > "${fluxbox_overlay}" <<'EOF'
background: unset
EOF
fi

rm -f "${fluxbox_lastwallpaper}"

if [ ! -f "${fluxbox_apps}" ] || ! grep -q "codex-maximize-browser" "${fluxbox_apps}"; then
  cat >> "${fluxbox_apps}" <<'EOF'

# codex-maximize-browser
[app] (class=Chromium)
  [Maximized] {yes}
[end]
[app] (class=chromium)
  [Maximized] {yes}
[end]
[app] (class=Google-chrome)
  [Maximized] {yes}
[end]
[app] (class=google-chrome)
  [Maximized] {yes}
[end]
EOF
fi

Xvfb "${DISPLAY}" -screen 0 "${SCREEN_RES}" &
fluxbox &
x11vnc -display "${DISPLAY}" -forever -shared -rfbport "${VNC_PORT}" -nopw &
websockify --web=/usr/share/novnc/ "${NOVNC_PORT}" "localhost:${VNC_PORT}" &

exec npx -y @playwright/mcp@"${PLAYWRIGHT_MCP_VERSION}" \
  --host 0.0.0.0 \
  --port "${MCP_PORT}" \
  --allowed-hosts "browser:${MCP_PORT},localhost:${MCP_PORT}" \
  --config /app/mcp.config.json \
  --no-sandbox \
  --isolated
