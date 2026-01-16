#!/usr/bin/env bash
set -euo pipefail

if [ "${MARINER_DEVCONTAINER:-}" != "1" ]; then
  echo "Expected MARINER_DEVCONTAINER=1; refusing to proceed."
  exit 1
fi

ready_timeout_seconds=120
poll_interval_seconds=2

wait_for() {
  local name="$1"
  local cmd="$2"
  local elapsed=0

  echo "Waiting for ${name}..."
  until eval "${cmd}" >/dev/null 2>&1; do
    if [ "${elapsed}" -ge "${ready_timeout_seconds}" ]; then
      echo "Timed out waiting for ${name} after ${ready_timeout_seconds}s."
      return 1
    fi
    sleep "${poll_interval_seconds}"
    elapsed=$((elapsed + poll_interval_seconds))
  done
  echo "${name} is ready."
}

echo "Running dev container health checks..."

echo "Tooling:"
echo "node: $(node --version)"
echo "npm: $(npm --version)"
echo "java: $(java -version 2>&1 | head -n 1)"
echo "psql: $(psql --version)"

wait_for "db" "PGPASSWORD=mariner psql -h db -U mariner -d mariner -c 'select 1;'"
wait_for "api" "curl -sS --max-time 2 http://api:8080/health"
# Ensure Host header matches Vite allowedHosts (service name is "web").
wait_for "web (vite)" "curl -sS --max-time 2 -H 'Host: web' http://web:5173/ | head -n 1"
wait_for "browser (noVNC)" "curl -sS --max-time 2 http://browser:6080/vnc.html | head -n 1"

echo "Health checks passed."
