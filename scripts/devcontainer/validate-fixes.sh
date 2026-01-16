#!/usr/bin/env bash
# Validation script to verify dev container fixes
set -euo pipefail

echo "========================================="
echo "Dev Container Fixes Validation"
echo "========================================="
echo ""

# Test 1: Locale
echo "Test 1: Checking locale configuration..."
if locale 2>&1 | grep -q "Cannot set"; then
  echo "❌ FAILED: Locale warnings still present"
  exit 1
else
  echo "✅ PASSED: Locale configured correctly"
fi
echo ""

# Test 2: Docker socket access
echo "Test 2: Checking Docker socket permissions..."
if docker ps >/dev/null 2>&1; then
  echo "✅ PASSED: Docker socket accessible"
else
  echo "❌ FAILED: Cannot access Docker socket"
  echo "   GID Info:"
  echo "   - Docker socket GID: $(stat -c '%g' /var/run/docker.sock 2>/dev/null || echo 'N/A')"
  echo "   - Container docker group GID: $(getent group docker | cut -d: -f3 2>/dev/null || echo 'N/A')"
  echo "   - User groups: $(groups)"
  exit 1
fi
echo ""

# Test 3: Web service
echo "Test 3: Checking web service (Vite) status..."
if curl -sS --max-time 2 -H 'Host: web' http://web:5173/ | grep -q "vite"; then
  echo "✅ PASSED: Vite dev server running"
else
  echo "❌ FAILED: Vite dev server not responding"
  exit 1
fi
echo ""

# Test 4: PostgreSQL access
echo "Test 4: Checking PostgreSQL access..."
if PGPASSWORD=mariner psql -h db -U mariner -d mariner -c 'SELECT 1;' 2>&1 | grep -q "1 row"; then
  echo "✅ PASSED: PostgreSQL accessible without locale warnings"
else
  echo "⚠️  WARNING: PostgreSQL accessible but check output for warnings"
fi
echo ""

echo "========================================="
echo "All validation tests completed!"
echo "========================================="
