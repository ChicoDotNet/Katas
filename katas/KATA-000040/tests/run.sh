#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p evidence
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swift --version | head -2
go version
swiftc -O tests/red/OrderedSet.swift tests/native/main.swift -o "$work/red"
if "$work/red" >evidence/red.txt 2>&1; then echo 'RED DID NOT FAIL' >&2; exit 1; fi
if ! grep -q 'NATIVE FAIL' evidence/red.txt; then echo 'RED failure not behavioral' >&2; exit 1; fi
printf 'RED compiled and failed behaviorally\n'
swiftc -O src/OrderedSet.swift tests/native/main.swift -o "$work/native"
"$work/native" | tee evidence/green.txt
swiftc -O src/OrderedSet.swift src/main.swift -o "$work/set-driver"
(cd tests/oracle && SWIFT_SET_BINARY="$work/set-driver" go test -race -count=1 -v ./...) | tee evidence/oracle.txt
(cd tests/oracle && go vet ./...)
python3 tests/mutations.py | tee evidence/mutations.txt
printf 'FULL SUITE PASS\n'
