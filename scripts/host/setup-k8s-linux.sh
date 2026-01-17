#!/usr/bin/env bash
# Host setup script for Mariner development environment (WSL2/Linux)
#
# This script installs all prerequisites and sets up the Kubernetes cluster.
# Safe to run multiple times (idempotent).
#
# Prerequisites (for WSL2):
#   - WSL2 with systemd enabled (Ubuntu 22.04+ on Windows 11 has this by default)
#   - If systemd is not enabled, create /etc/wsl.conf with [boot] systemd=true
#     and restart WSL with: wsl --shutdown
#
# For macOS, use setup-k8s-macos.sh instead.
set -euo pipefail

CLUSTER_NAME="mariner-dev"
REGISTRY_NAME="mariner-registry"
REGISTRY_PORT="5005"

echo "========================================"
echo "Mariner Development Environment Setup"
echo "========================================"
echo ""

# Detect OS
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS_ID="${ID:-unknown}"
  OS_ID_LIKE="${ID_LIKE:-}"
else
  OS_ID="unknown"
  OS_ID_LIKE=""
fi

echo "Detected OS: ${OS_ID} (${OS_ID_LIKE})"

# Helper to check if running in WSL
is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

# ============================================================================
# WSL2-specific checks
# ============================================================================
if is_wsl; then
  echo "Detected: Running in WSL2"

  # Check if systemd is enabled (required for Docker)
  if ! systemctl --version &> /dev/null; then
    echo ""
    echo "ERROR: systemd is not available in this WSL instance."
    echo ""
    echo "Docker requires systemd. To enable it:"
    echo "  1. Create or edit /etc/wsl.conf:"
    echo "     sudo bash -c 'echo -e \"[boot]\\nsystemd=true\" > /etc/wsl.conf'"
    echo "  2. Restart WSL from PowerShell:"
    echo "     wsl --shutdown"
    echo "  3. Re-open your WSL terminal and run this script again."
    echo ""
    exit 1
  fi
  echo "systemd is enabled."
fi

# Helper to install packages based on distro
install_package() {
  local package="$1"

  if command -v apt-get &> /dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y "$package"
  elif command -v dnf &> /dev/null; then
    sudo dnf install -y "$package"
  elif command -v yum &> /dev/null; then
    sudo yum install -y "$package"
  elif command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm "$package"
  else
    echo "ERROR: Could not detect package manager. Please install '$package' manually."
    exit 1
  fi
}

# ============================================================================
# Step 1: Install essential prerequisites
# ============================================================================
echo ""
echo "[1/5] Installing essential prerequisites..."

if command -v apt-get &> /dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y ca-certificates curl git
elif command -v dnf &> /dev/null; then
  sudo dnf install -y ca-certificates curl git
elif command -v yum &> /dev/null; then
  sudo yum install -y ca-certificates curl git
fi

echo "Prerequisites installed: curl $(curl --version | head -1 | cut -d' ' -f2), git $(git --version | cut -d' ' -f3)"

# ============================================================================
# Step 2: Install Docker
# ============================================================================
echo ""
echo "[2/5] Checking Docker..."

if ! command -v docker &> /dev/null; then
  echo "Docker not found. Installing..."

  if [[ "$OS_ID" == "ubuntu" ]] || [[ "$OS_ID_LIKE" == *"debian"* ]] || [[ "$OS_ID" == "debian" ]]; then
    # Install Docker on Debian/Ubuntu (following official docs)
    # https://docs.docker.com/engine/install/ubuntu/
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl

    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL "https://download.docker.com/linux/${OS_ID}/gpg" -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository (using deb822 format)
    # shellcheck disable=SC2027,SC2046
    echo "Types: deb
URIs: https://download.docker.com/linux/${OS_ID}
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  elif [[ "$OS_ID" == "fedora" ]]; then
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  else
    echo "ERROR: Automatic Docker installation not supported for ${OS_ID}."
    echo "Please install Docker manually: https://docs.docker.com/get-docker/"
    exit 1
  fi

  # Start Docker service
  sudo systemctl enable docker
  sudo systemctl start docker

  echo "Docker installed successfully."
else
  echo "Docker is already installed: $(docker --version)"
fi

# Add current user to docker group if not already
# Use getent to check actual group membership (not just current session)
if ! getent group docker | grep -q "\b${USER}\b"; then
  echo "Adding $USER to docker group..."
  sudo usermod -aG docker "$USER"

  # Re-execute this script with the new group membership
  echo "Restarting script with docker group membership..."
  exec sg docker -c "$0 $*"
fi

# Check Docker daemon is running
if ! docker info &> /dev/null; then
  echo "Starting Docker daemon..."
  sudo systemctl start docker
  sleep 2
fi

if ! docker info &> /dev/null; then
  echo "ERROR: Docker daemon is not running and could not be started."
  echo "Try: sudo systemctl start docker"
  exit 1
fi

echo "Docker daemon is running."

# ============================================================================
# Step 3: Install kubectl
# ============================================================================
echo ""
echo "[3/5] Checking kubectl..."

if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found. Installing..."

  # Detect architecture
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64) KUBECTL_ARCH="amd64" ;;
    aarch64|arm64) KUBECTL_ARCH="arm64" ;;
    *) echo "ERROR: Unsupported architecture: $ARCH"; exit 1 ;;
  esac

  # Download latest stable kubectl
  KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/

  echo "kubectl installed: $(kubectl version --client 2>/dev/null | head -1)"
else
  echo "kubectl is already installed: $(kubectl version --client 2>/dev/null | head -1)"
fi

# ============================================================================
# Step 4: Install k3d
# ============================================================================
echo ""
echo "[4/5] Checking k3d..."

if ! command -v k3d &> /dev/null; then
  echo "k3d not found. Installing..."
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

echo "k3d version: $(k3d version | head -1)"

# ============================================================================
# Step 5: Create/verify k3d cluster
# ============================================================================
echo ""
echo "[5/5] Setting up Kubernetes cluster..."

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

# Update kubeconfig
echo "Updating kubeconfig..."
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
echo "  1. Install VS Code or Cursor (if not already installed)"
echo "     - VS Code: https://code.visualstudio.com/docs/setup/linux"
echo "     - Or on Windows with WSL: install VS Code on Windows, it auto-detects WSL"
echo "  2. Install the 'Dev Containers' extension in VS Code/Cursor"
echo "  3. Open the project: code ."
echo "  4. Reopen in Container (F1 -> 'Dev Containers: Reopen in Container')"
echo "  5. Run 'tilt up' to start the development stack"
echo ""
