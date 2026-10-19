#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
node --check src/clock-in.mjs
node --check src/cli.mjs
node --check tests/test-clock-in.mjs
set +e
NINJA_RED=1 node --test tests/test-clock-in.mjs > build/red.log 2>&1
red_status=$?
set -e
if [ "$red_status" -eq 0 ] || ! grep -q 'POST began before required GPS completed' build/red.log; then
  echo 'RED gate failed: expected behavioral ordering assertion' >&2
  cat build/red.log >&2
  exit 1
fi
echo 'RED: semantic ordering mutant rejected by node:test'
node --test tests/test-clock-in.mjs
go run tests/oracle.go src/cli.mjs
