#!/usr/bin/env bash
# Host setup script for Mariner development environment (macOS)
#
# This script installs all prerequisites and sets up the Kubernetes cluster.
# Safe to run multiple times (idempotent).
#
# Uses Colima for Docker runtime (lighter than Docker Desktop).
#
# For WSL2/Linux, use setup-k8s-linux.sh instead.
set -euo pipefail

CLUSTER_NAME="mariner-dev"
REGISTRY_NAME="mariner-registry"
REGISTRY_PORT="5005"

echo "========================================"
echo "Mariner Development Environment Setup"
echo "========================================"
echo ""

# Verify we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: This script is for macOS only."
  echo "For WSL2/Linux, use setup-k8s-linux.sh instead."
  exit 1
fi

echo "Detected: macOS $(sw_vers -productVersion)"

# ============================================================================
# Step 1: Install Homebrew (if needed)
# ============================================================================
echo ""
echo "[1/6] Checking Homebrew..."

if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "Homebrew is installed: $(brew --version | head -1)"
fi

# ============================================================================
# Step 2: Install Docker CLI and Colima
# ============================================================================
echo ""
echo "[2/6] Checking Docker (via Colima)..."

# Install Docker CLI if not present
if ! command -v docker &> /dev/null; then
  echo "Installing Docker CLI..."
  brew install docker
fi

# Install Colima if not present
if ! command -v colima &> /dev/null; then
  echo "Installing Colima..."
  brew install colima
fi

# Start Colima if not running
if ! colima status &> /dev/null; then
  echo "Starting Colima..."

  # Detect if running on Apple Silicon for optimal VM settings
  COLIMA_OPTS="--cpu 4 --memory 8 --disk 60"

  if [[ "$(uname -m)" == "arm64" ]]; then
    # Apple Silicon: use Virtualization.framework for better performance
    # Requires macOS 13+ for full support
    MACOS_VERSION=$(sw_vers -productVersion | cut -d. -f1)
    if [[ "$MACOS_VERSION" -ge 13 ]]; then
      COLIMA_OPTS="$COLIMA_OPTS --vm-type vz --mount-type virtiofs"
    else
      COLIMA_OPTS="$COLIMA_OPTS --mount-type sshfs"
    fi
  else
    # Intel: use default QEMU with sshfs
    COLIMA_OPTS="$COLIMA_OPTS --mount-type sshfs"
  fi

  echo "Colima options: $COLIMA_OPTS"
  # shellcheck disable=SC2086
  colima start $COLIMA_OPTS
fi

# Verify Docker is working
if ! docker info &> /dev/null; then
  echo "ERROR: Docker is not responding."
  echo "Try: colima status"
  echo "Or restart with: colima stop && colima start"
  exit 1
fi

echo "Docker is running via Colima: $(docker --version)"

# ============================================================================
# Step 3: Install kubectl
# ============================================================================
echo ""
echo "[3/6] Checking kubectl..."

if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found. Installing..."
  brew install kubectl
fi

echo "kubectl version: $(kubectl version --client 2>/dev/null | head -1)"

# ============================================================================
# Step 4: Install k3d
# ============================================================================
echo ""
echo "[4/6] Checking k3d..."

if ! command -v k3d &> /dev/null; then
  echo "k3d not found. Installing..."
  brew install k3d
fi

echo "k3d version: $(k3d version | head -1)"

# ============================================================================
# Step 5: Create/verify k3d cluster
# ============================================================================
echo ""
echo "[5/6] Setting up Kubernetes cluster..."

# Check if cluster already exists
if k3d cluster list 2>/dev/null | grep -q "^${CLUSTER_NAME} "; then
  echo "Cluster '${CLUSTER_NAME}' already exists."

  # Check if it's running
  if k3d cluster list | grep "^${CLUSTER_NAME} " | grep -q "1/1"; then
    echo "Cluster is running."
  else
    echo "Starting cluster..."
    k3d cluster start "${CLUSTER_NAME}"
  fi
else
  echo "Creating k3d cluster '${CLUSTER_NAME}'..."

  # Create registry if it doesn't exist
  if ! k3d registry list 2>/dev/null | grep -q "${REGISTRY_NAME}"; then
    echo "Creating local registry '${REGISTRY_NAME}' on port ${REGISTRY_PORT}..."
    k3d registry create "${REGISTRY_NAME}" --port "${REGISTRY_PORT}"
  fi

  # Create cluster with registry
  k3d cluster create "${CLUSTER_NAME}" \
    --registry-use "k3d-${REGISTRY_NAME}:${REGISTRY_PORT}" \
    --port "8080:80@loadbalancer" \
    --port "8443:443@loadbalancer" \
    --wait
fi

# ============================================================================
# Step 6: Configure kubeconfig
# ============================================================================
echo ""
echo "[6/6] Configuring kubeconfig..."

mkdir -p "${HOME}/.kube"
k3d kubeconfig merge "${CLUSTER_NAME}" --kubeconfig-merge-default

# Verify cluster access
echo ""
echo "Verifying cluster access..."
if kubectl cluster-info &> /dev/null; then
  echo "Cluster is accessible."
  kubectl get nodes
else
  echo "WARNING: kubectl cannot reach the cluster."
  echo "You may need to check your kubeconfig."
fi

# ============================================================================
# Done
# ============================================================================
echo ""
echo "========================================"
echo "Setup complete!"
echo "========================================"
echo ""
echo "Cluster: ${CLUSTER_NAME}"
echo "Registry: localhost:${REGISTRY_PORT} (k3d-${REGISTRY_NAME}:${REGISTRY_PORT} from containers)"
echo ""
echo "Next steps:"
echo "  1. Open the project in VS Code: code ."
echo "  2. Reopen in Container (F1 -> 'Dev Containers: Reopen in Container')"
echo "  3. Run 'tilt up' to start the development stack"
echo ""
echo "Colima commands:"
echo "  colima status   - Check status"
echo "  colima stop     - Stop VM (preserves state)"
echo "  colima start    - Start VM"
echo "  colima delete   - Delete VM (removes all data)"
echo ""
