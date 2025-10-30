#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./setup.sh [--hunter-key KEY]
#
# This script will:
#   - ensure Python venv is available (instruct to install python3-venv if missing)
#   - create .venv
#   - install requirements and package (editable)
#   - optionally write .env with HUNTER_API_KEY if provided

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

HUNTER_KEY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hunter-key)
      HUNTER_KEY="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# Check venv availability
if ! python3 -m venv --help >/dev/null 2>&1; then
  echo "python3-venv is not installed. Install it and re-run:" >&2
  echo "  sudo apt-get update -y && sudo apt-get install -y python3-venv" >&2
  exit 1
fi

# Create venv if missing
if [[ ! -d .venv ]]; then
  python3 -m venv .venv
fi

# Activate and install deps
# shellcheck disable=SC1091
source .venv/bin/activate
python -m pip install -U pip
pip install -r requirements.txt
pip install -e .

# Write .env if key provided
if [[ -n "$HUNTER_KEY" ]]; then
  printf 'HUNTER_API_KEY=%s\n' "$HUNTER_KEY" > .env
  echo ".env written with HUNTER_API_KEY"
fi

echo "Setup complete. Activate with: source .venv/bin/activate"
