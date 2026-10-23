#!/usr/bin/env bash
# Resolve a Taskfile var with precedence: shell/CLI env > .env file > default.
# Taskfile v3 dotenv values aren't visible to `sh:` blocks in `vars:`, so we
# read .env directly here instead of relying on it being exported already.
#
# Usage: env-default.sh VAR_NAME [DEFAULT]
set -eu

var="$1"
default="${2:-}"

env_val=$(eval "echo \"\${$var:-}\"")
file_val=$(grep -m1 "^${var}=" .env 2>/dev/null | cut -d= -f2-)

echo "${env_val:-${file_val:-$default}}"
