#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
swiftc --version
ruby --version
swiftc -parse-as-library -swift-version 6 -warnings-as-errors tests/RedStub.swift tests/RedBehavior.swift -o "$TMP/red"
if "$TMP/red" >"$TMP/red.log" 2>&1; then echo 'FAIL: RED unexpectedly passed' >&2; exit 1; fi
grep -q 'FAIL behavioral assertion: duplicate robot names' "$TMP/red.log"
echo 'RED Swift compiled and failed behaviorally: duplicate robot names'
swiftc -parse-as-library -swift-version 6 -warnings-as-errors -O src/RobotFactory.swift tests/NativeTests.swift -o "$TMP/native"
"$TMP/native"
swiftc -parse-as-library -swift-version 6 -warnings-as-errors -sanitize=thread -O src/RobotFactory.swift tests/NativeTests.swift -o "$TMP/native-tsan"
"$TMP/native-tsan"
echo "THREAD SANITIZER PASS: native Swift actor concurrency suite"
swiftc -parse-as-library -swift-version 6 -warnings-as-errors -O src/RobotFactory.swift src/CLI.swift -o "$TMP/cli"
ruby tests/oracle.rb "$TMP/cli"
for mutant in MUTANT_IGNORE_OCCUPIED MUTANT_RESET_REUSES; do
  swiftc -parse-as-library -swift-version 6 -warnings-as-errors -O -D "$mutant" src/RobotFactory.swift tests/NativeTests.swift -o "$TMP/$mutant"
  if "$TMP/$mutant" >"$TMP/$mutant.log" 2>&1; then echo "FAIL: mutant $mutant survived" >&2; exit 1; fi
  grep -q 'FAIL behavioral assertion:' "$TMP/$mutant.log"
  echo "MUTANT $mutant killed by native Swift behavioral assertion"
done
echo 'FULL SUITE PASS'
