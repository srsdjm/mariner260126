#!/bin/bash
# Firewall management script for the dev container
# Usage: ./scripts/firewall.sh [strict|permissive|disable|status]

set -euo pipefail

MODE="${1:-status}"

case "$MODE" in
  strict)
    echo "Enabling firewall in STRICT mode..."
    echo "This will block all outbound traffic except explicitly allowed domains."
    sudo FIREWALL_MODE=strict /usr/local/bin/init-firewall.sh
    echo ""
    echo "Firewall is now in STRICT mode."
    echo "To disable: ./scripts/firewall.sh disable"
    ;;

  permissive)
    echo "Enabling firewall in PERMISSIVE mode..."
    echo "This will allow all outbound traffic."
    sudo FIREWALL_MODE=permissive /usr/local/bin/init-firewall.sh
    echo ""
    echo "Firewall is now in PERMISSIVE mode."
    echo "To disable: ./scripts/firewall.sh disable"
    ;;

  disable)
    echo "Disabling firewall..."
    sudo FIREWALL_MODE=disabled /usr/local/bin/init-firewall.sh
    echo ""
    echo "Firewall is now DISABLED."
    echo "To enable strict mode: ./scripts/firewall.sh strict"
    echo "To enable permissive mode: ./scripts/firewall.sh permissive"
    ;;

  status)
    echo "Firewall Status"
    echo "==============="
    echo ""
    echo "Current iptables rules:"
    sudo iptables -L -n -v | head -20
    echo ""
    echo "Available commands:"
    echo "  ./scripts/firewall.sh strict      - Enable strict mode (block all except allowed)"
    echo "  ./scripts/firewall.sh permissive  - Enable permissive mode (allow all)"
    echo "  ./scripts/firewall.sh disable     - Disable firewall"
    echo "  ./scripts/firewall.sh status      - Show current status (this command)"
    ;;

  *)
    echo "Unknown mode: $MODE"
    echo "Usage: ./scripts/firewall.sh [strict|permissive|disable|status]"
    exit 1
    ;;
esac
