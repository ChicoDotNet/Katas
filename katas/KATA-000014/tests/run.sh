#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build
trap 'rm -rf .build' EXIT
swiftc -swift-version 6 -warnings-as-errors -parse-as-library tests/Red.swift tests/NativeTests.swift -o .build/red
if .build/red >.build/red.out 2>&1; then echo 'FAIL RED: stub unexpectedly passed'; exit 1; fi
grep -q 'FAIL native: 250cm has exactly five' .build/red.out
echo 'RED compiled and failed on intended behavioral assertion'
swiftc -swift-version 6 -warnings-as-errors -parse-as-library src/Wardrobe.swift tests/NativeTests.swift -o .build/native
.build/native
swiftc -swift-version 6 -warnings-as-errors src/Wardrobe.swift src/main.swift -o .build/wardrobe
go vet tests/oracle.go
go run tests/oracle.go .build/wardrobe
python3 tests/mutations.py
