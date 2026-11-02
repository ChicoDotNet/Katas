#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo 'TOOLCHAINS:'
node --version; tsc --version; go version; python3 --version
red=$(mktemp -d)
trap 'rm -rf "$red"' EXIT
mkdir -p "$red/src" "$red/tests"
cp tsconfig.json package.json "$red/"
cp src/cli.mjs "$red/src/"
cp tests/native.test.mjs "$red/tests/"
cp tests/red-stub.ts "$red/src/network.ts"
(cd "$red" && tsc -p tsconfig.json)
set +e
(cd "$red" && node --test tests/native.test.mjs) > "$red/red.log" 2>&1
status=$?
set -e
if [[ $status -eq 0 ]] || ! grep -q 'not ok' "$red/red.log"; then cat "$red/red.log"; echo 'RED invalid: no behavioral failure' >&2; exit 1; fi
echo 'RED compiled, behaviorally failed as expected'
tsc -p tsconfig.json
node --test tests/native.test.mjs
go vet tests/oracle.go
go run tests/oracle.go
python3 tests/mutations.py
