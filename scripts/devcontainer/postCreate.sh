#!/usr/bin/env bash
# Runs via Dev Container postCreateCommand (on container create/rebuild).
set -euo pipefail

if [ "${MARINER_DEVCONTAINER:-}" != "1" ]; then
  echo "Expected MARINER_DEVCONTAINER=1; refusing to proceed."
  exit 1
fi

echo "========================================"
echo "Devcontainer post-create setup"
echo "========================================"

# Configure Tilt telemetry opt-out
echo ""
echo "Configuring Tilt settings..."
mkdir -p ~/.tilt-dev
cat > ~/.tilt-dev/config.json <<EOF
{
  "analytics": {
    "opt": "opt-out"
  }
}
EOF
echo "✓ Tilt telemetry disabled"

# Verify Kubernetes cluster connectivity (cluster runs on host via k3d)
echo ""
echo "Checking Kubernetes cluster connectivity..."
if kubectl cluster-info &> /dev/null; then
  echo "✓ Connected to Kubernetes cluster"
  kubectl get nodes
else
  echo ""
  echo "⚠ WARNING: Cannot connect to Kubernetes cluster."
  echo ""
  echo "The k3d cluster should be running on your host machine."
  echo "Run one of these on your host (outside the container):"
  echo ""
  echo "  Linux/WSL2: ./scripts/host/setup-k8s-linux.sh"
  echo "  macOS:      ./scripts/host/setup-k8s-macos.sh"
  echo ""
  echo "Then rebuild the devcontainer."
  echo ""
  # Don't fail - allow container to start so user can debug
fi

echo ""
echo "========================================"
echo "Devcontainer post-create complete."
echo "========================================"
