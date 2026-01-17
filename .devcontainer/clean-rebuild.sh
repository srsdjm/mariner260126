#!/usr/bin/env bash
# Clean up Docker state before rebuilding the devcontainer.
# Run this from the host (not inside the container) before triggering a rebuild.
set -euo pipefail

echo "Cleaning up devcontainer state..."

# Stop and remove any devcontainers for this project
CONTAINERS=$(docker ps -aq --filter "label=devcontainer.local_folder" 2>/dev/null || true)
if [ -n "$CONTAINERS" ]; then
  echo "Removing containers..."
  echo "$CONTAINERS" | xargs docker rm -f 2>/dev/null || true
fi

# Remove the built images for this project
IMAGES=$(docker images --filter "reference=vsc-mariner260116*" -q 2>/dev/null || true)
if [ -n "$IMAGES" ]; then
  echo "Removing images..."
  echo "$IMAGES" | xargs docker rmi -f 2>/dev/null || true
fi

echo "Cleanup complete. You can now rebuild the devcontainer."
