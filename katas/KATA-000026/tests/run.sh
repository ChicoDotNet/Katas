#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build
kotlinc tests/Stub.kt tests/NativeTests.kt -include-runtime -d .build/red.jar
if java -cp .build/red.jar NativeTests > .build/red.log 2>&1; then echo 'RED unexpectedly passed' >&2; exit 1; fi
grep -q 'behavior expected=' .build/red.log || { echo 'RED did not fail behaviorally' >&2; exit 1; }
echo 'RED compiled and failed behaviorally'
kotlinc src/TaskBook.kt tests/NativeTests.kt -include-runtime -d .build/native.jar
java -cp .build/native.jar NativeTests
kotlinc src/TaskBook.kt src/Main.kt -include-runtime -d .build/app.jar
python3 tests/cli_contract.py "$(pwd)/.build/app.jar"
go vet tests/oracle.go
go run tests/oracle.go "$(pwd)/.build/app.jar"
python3 tests/mutations.py
