#!/usr/bin/env sh
set -eu
root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
test -f "$root/hooks/pre-commit" || {
  echo "Hook files are missing. Generate a runnable profile before installing hooks." >&2
  exit 1
}
chmod +x "$root/hooks/pre-commit" "$root/hooks/pre-push" 2>/dev/null || true
chmod +x "$root/scripts/install-hooks.sh" 2>/dev/null || true
if [ -f "$root/mvnw" ]; then
  chmod +x "$root/mvnw" 2>/dev/null || true
fi
git -C "$root" config core.hooksPath hooks
echo "Git hooks enabled for this clone. A human remains responsible for Git actions."
