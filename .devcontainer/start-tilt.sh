#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================="
echo "Mariner K8s Development Environment"
echo "==================================================${NC}"

# ============================================================================
# Wait for cluster to be ready
# ============================================================================
echo -e "${BLUE}⏳ Waiting for Kubernetes cluster to be ready...${NC}"

MAX_RETRIES=30
RETRY_COUNT=0

while ! kubectl cluster-info &> /dev/null; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo -e "${RED}❌ Kubernetes cluster not ready after ${MAX_RETRIES} attempts${NC}"
        echo ""
        echo "The k3d cluster should be running on your host machine."
        echo "Run one of these on your host (outside the container):"
        echo "  Linux/WSL2: ./scripts/host/setup-k8s-linux.sh"
        echo "  macOS:      ./scripts/host/setup-k8s-macos.sh"
        exit 1
    fi
    echo -e "${YELLOW}Waiting for cluster... (attempt $RETRY_COUNT/$MAX_RETRIES)${NC}"
    sleep 2
done

echo -e "${GREEN}✓ Kubernetes cluster is ready${NC}"

# ============================================================================
# Print helpful information
# ============================================================================
echo ""
echo -e "${GREEN}=================================================="
echo "Ready to start development!"
echo "==================================================${NC}"
echo ""
echo "To start all services, run:"
echo -e "  ${BLUE}tilt up${NC}"
echo ""
echo "Or run in the background:"
echo -e "  ${BLUE}tilt up &${NC}"
echo ""
echo "Services will be available at:"
echo "  • Web (Vite):      http://localhost:5173"
echo "  • API (Ktor):      http://localhost:8080/health"
echo "  • Browser (noVNC): http://localhost:6080"
echo "  • Tilt UI:         http://localhost:10350"
echo ""
echo "Debug:"
echo "  • JDWP debugger:   localhost:5005"
echo ""
echo "Database:"
echo "  • PostgreSQL:      localhost:5432"
echo "    - Username:      mariner"
echo "    - Password:      mariner"
echo "    - Database:      mariner"
echo ""
echo "Useful commands:"
echo "  • kubectl get pods -n mariner-dev     - View running pods"
echo "  • kubectl logs -f <pod-name> -n mariner-dev - View logs"
echo "  • tilt down                            - Stop all services"
echo ""
