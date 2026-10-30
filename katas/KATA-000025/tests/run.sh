#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build
ulimit -c 0 || true
swiftc -swift-version 6 -warnings-as-errors tests/Stub.swift tests/NativeTests.swift -o .build/red
if .build/red >.build/red.log 2>&1; then
  echo 'RED unexpectedly passed' >&2; exit 1
fi
if ! grep -q 'expected sum' .build/red.log; then
  echo 'RED did not fail behaviorally' >&2; exit 1
fi
echo 'RED compiled, failed behaviorally as expected'
swiftc -swift-version 6 -warnings-as-errors src/Calculator.swift tests/NativeTests.swift -o .build/native
.build/native
swiftc -swift-version 6 -warnings-as-errors src/Calculator.swift src/main.swift -o .build/calculator
go vet tests/oracle.go
go run tests/oracle.go "$(pwd)/.build/calculator"
python3 tests/mutations.py
