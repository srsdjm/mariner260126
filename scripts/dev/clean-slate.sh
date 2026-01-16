#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "This will remove all Mariner Compose containers and volumes."
echo "It clears database data, web node_modules, Cursor Server settings, and Gradle caches."
read -r -p "Type 'reset' to continue: " CONFIRM_RESET
if [[ "$CONFIRM_RESET" != "reset" ]]; then
  echo "Aborted."
  exit 1
fi

cd "$REPO_ROOT"
docker compose \
  -f compose.yml \
  -f compose.dev.yml \
  -f .devcontainer/compose.devcontainer.yml \
  down --remove-orphans --volumes
