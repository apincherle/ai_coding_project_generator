#!/usr/bin/env sh
set -eu
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
test -f "$root/hooks/pre-commit" || {
  echo "Hook files are missing. Generate a runnable profile before installing hooks." >&2
  exit 1
}
git -C "$root" config core.hooksPath hooks
echo "Git hooks enabled for this clone. A human remains responsible for Git actions."
