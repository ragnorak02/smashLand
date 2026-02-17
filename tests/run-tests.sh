#!/usr/bin/env bash
# SmashLand test runner — CI wrapper
# Usage: ./tests/run-tests.sh
# Set GODOT_BIN to override the Godot binary path.

set -euo pipefail

# Resolve Godot binary
if [ -n "${GODOT_BIN:-}" ]; then
  GODOT="$GODOT_BIN"
elif command -v godot &>/dev/null; then
  GODOT="godot"
else
  echo '{"status":"error","message":"Godot binary not found. Set GODOT_BIN or add godot to PATH."}' >&2
  exit 1
fi

# Resolve project root (parent of tests/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

exec "$GODOT" --headless --path "$PROJECT_DIR" --script tests/run-tests.gd
