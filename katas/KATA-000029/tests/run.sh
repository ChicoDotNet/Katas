#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
KATA=katas/KATA-000029
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
java -version 2>&1 | head -1
go version
mkdir -p "$TMP/red" "$TMP/green"
javac --release 21 -d "$TMP/red" "$KATA/tests/Stub.java" "$KATA/tests/NativeTests.java"
if java -cp "$TMP/red" NativeTests >"$TMP/red.out" 2>&1; then
  echo 'ERROR: RED stub unexpectedly passed' >&2; exit 1
fi
if ! grep -q 'AssertionError: board=' "$TMP/red.out"; then
  cat "$TMP/red.out" >&2; echo 'ERROR: RED did not fail behaviorally' >&2; exit 1
fi
echo 'RED compilable, behavioral failure confirmed'
javac --release 21 -d "$TMP/green" "$KATA/src/TicTacToe.java" "$KATA/src/Main.java" "$KATA/tests/NativeTests.java"
java -cp "$TMP/green" NativeTests
go vet "$KATA/tests/oracle.go"
go run "$KATA/tests/oracle.go" "$TMP/green"
python3 "$KATA/tests/mutations.py" "$TMP/green"
