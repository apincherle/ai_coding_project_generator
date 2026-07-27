#!/usr/bin/env sh
set -eu
export PATH="/app/.venv/bin:${PATH}"
exec "$@"
