#!/usr/bin/env bash
set -euo pipefail

docker compose -f compose.yml -f compose.dev.yml logs -f web
