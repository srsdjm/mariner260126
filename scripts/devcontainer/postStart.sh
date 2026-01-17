set -euo pipefail

if [ "${MARINER_DEVCONTAINER:-}" != "1" ]; then
  echo "Expected MARINER_DEVCONTAINER=1; refusing to proceed."
  exit 1
fi

# Fix docker socket permissions by adjusting docker group GID if needed
if [ -S /var/run/docker.sock ] || [ -S /var/run/docker-host.sock ]; then
  DOCKER_SOCK_PATH=/var/run/docker.sock
  if [ -L "$DOCKER_SOCK_PATH" ]; then
    DOCKER_SOCK_PATH=$(readlink -f "$DOCKER_SOCK_PATH")
  fi

  if [ -S "$DOCKER_SOCK_PATH" ]; then
    DOCKER_SOCK_GID=$(stat -c '%g' "$DOCKER_SOCK_PATH")
    CURRENT_DOCKER_GID=$(getent group docker | cut -d: -f3)

    if [ "$DOCKER_SOCK_GID" != "$CURRENT_DOCKER_GID" ]; then
      echo "Adjusting docker group GID from $CURRENT_DOCKER_GID to $DOCKER_SOCK_GID"
      sudo groupmod -g "$DOCKER_SOCK_GID" docker 2>/dev/null || echo "Note: Could not adjust docker group GID"
      # Re-add user to group with new GID (group membership refresh)
      sudo usermod -aG docker vscode 2>/dev/null || true
    fi
  fi
fi

# Fix kubeconfig for devcontainer
# k3d creates kubeconfig with server: https://0.0.0.0:PORT which doesn't work from containers
# Replace with Docker host gateway IP to access the API port exposed by k3d
if [ -f ~/.kube/config ] && grep -q "server: https://0.0.0.0:" ~/.kube/config; then
  DOCKER_HOST_IP=$(ip route show | grep default | awk '{print $3}')
  sed -i "s|server: https://0.0.0.0:|server: https://$DOCKER_HOST_IP:|g" ~/.kube/config
fi

echo "Devcontainer ready."
echo "node: $(node --version)"
echo "npm: $(npm --version)"
echo "java: $(java -version 2>&1 | head -n 1)"

git config --global --add safe.directory /workspace >/dev/null 2>&1 || true

# Show Tilt/K8s instructions
bash .devcontainer/start-tilt.sh

bash scripts/devcontainer/healthcheck.sh
