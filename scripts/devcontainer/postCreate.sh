#!/usr/bin/env bash
# Runs via Dev Container postCreateCommand (on container create/rebuild).
set -euo pipefail

if [ "${MARINER_DEVCONTAINER:-}" != "1" ]; then
  echo "Expected MARINER_DEVCONTAINER=1; refusing to proceed."
  exit 1
fi

echo "Devcontainer post-create complete."
