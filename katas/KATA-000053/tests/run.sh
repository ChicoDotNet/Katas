#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v swiftc >/dev/null || { echo 'BLOCKED: authentic Swift compiler unavailable'; exit 78; }
command -v go >/dev/null || { echo 'BLOCKED: authentic Go compiler unavailable'; exit 78; }
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
swiftc -swift-version 6 -D KATA_RED src/POV.swift tests/Native.swift -o "$work/red"
if "$work/red" > "$work/red.log" 2>&1; then echo 'ERROR: RED unexpectedly passed' >&2; exit 1; fi
grep -q 'FAIL behavioral assertion' "$work/red.log"
echo 'RED compiled, failed on behavior as expected'
swiftc -swift-version 6 src/POV.swift tests/Native.swift -o "$work/green"
"$work/green"
swiftc -swift-version 6 -O src/POV.swift src/Main.swift -o "$work/pov-cli"
go test -race tests/oracle.go tests/oracle_test.go
go run tests/oracle.go "$work/pov-cli"
for mutant in KATA_MUTANT_DROP_SIBLINGS KATA_MUTANT_REVERSE_PATH; do
  swiftc -swift-version 6 -D "$mutant" src/POV.swift tests/Native.swift -o "$work/mutant"
  if "$work/mutant" > "$work/mutant.log" 2>&1; then echo "ERROR: $mutant survived" >&2; exit 1; fi
  grep -q 'FAIL behavioral assertion' "$work/mutant.log"
  echo "MUTANT KILLED: $mutant"
done
echo 'POV suite PASS'
