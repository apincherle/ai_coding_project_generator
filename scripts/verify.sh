#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/../examples/spring-api"
mvn verify
