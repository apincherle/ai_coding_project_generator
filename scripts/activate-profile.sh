#!/usr/bin/env sh
set -eu

profile="${1:-}"
case "$profile" in
  java|python|csharp|c|cpp|rust|scala|typescript-node|javascript-node|react-typescript|nextjs-typescript) ;;
  *) echo "Usage: $0 <java|python|csharp|c|cpp|rust|scala|typescript-node|javascript-node|react-typescript|nextjs-typescript>" >&2; exit 2 ;;
esac

repository_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
for file in project.md coding-standards.md testing.md dependencies.md; do
  cp "$repository_root/.ai/profiles/$profile/$file" "$repository_root/.ai/$file"
done

echo "Activated profile '$profile'. Review the four changed .ai files before committing."
