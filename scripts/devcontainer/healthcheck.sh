#!/usr/bin/env bash
# Health check for K8s-based development environment
set -euo pipefail

if [ "${MARINER_DEVCONTAINER:-}" != "1" ]; then
  echo "Expected MARINER_DEVCONTAINER=1; refusing to proceed."
  exit 1
fi

echo "Running devcontainer health checks..."
echo ""

# Check tooling versions
echo "Tooling:"
echo "  node: $(node --version)"
echo "  npm: $(npm --version)"
echo "  java: $(java -version 2>&1 | head -n 1)"
echo "  psql: $(psql --version | head -n 1)"
echo "  kubectl: $(kubectl version --client 2>/dev/null | head -n 1)"
echo "  tilt: $(tilt version 2>/dev/null || echo 'not installed')"
echo "  docker: $(docker --version)"
echo ""

# Check Kubernetes connectivity
echo "Kubernetes cluster:"
if kubectl cluster-info &> /dev/null; then
  echo "  ✓ Connected to cluster"
  kubectl get nodes --no-headers 2>/dev/null | while read -r line; do
    echo "    $line"
  done
else
  echo "  ⚠ Not connected (run setup script on host)"
fi
echo ""

# Check Docker connectivity
echo "Docker:"
if docker info &> /dev/null; then
  echo "  ✓ Docker daemon accessible"
else
  echo "  ⚠ Docker daemon not accessible"
fi
echo ""

echo "Health checks complete."
echo ""
echo "To start the development stack, run: tilt up"
