#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
javac -Xlint:all -Werror -d build src/*.java tests/*.java
set +e
java -cp build TestTelemetryControl red > build/red.log 2>&1
red_status=$?
set -e
if [ "$red_status" -eq 0 ] || ! grep -q 'wrong result' build/red.log; then
  echo 'RED gate failed: expected behavioral assertion' >&2
  cat build/red.log >&2
  exit 1
fi
echo 'RED: intentional behavioral mutant rejected by Java tests'
java -cp build TestTelemetryControl
node tests/telemetry_oracle.mjs build
