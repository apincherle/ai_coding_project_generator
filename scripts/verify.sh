#!/usr/bin/env sh
set -eu

repository_root="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
if [ -f "$repository_root/pom.xml" ]; then
  java_root="$repository_root"
elif [ -f "$repository_root/templates/java/pom.xml" ]; then
  java_root="$repository_root/templates/java"
else
  echo "Java verification failed: no root or templates/java pom.xml was found." >&2
  exit 1
fi

cd "$java_root"
mvn verify
