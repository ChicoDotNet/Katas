#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)";trap 'rm -rf "$tmp"' EXIT
# Compile a deliberately wrong, type-correct stub; behavioral RED must fail.
cp tests/Stub.hpp "$tmp/yatzy.hpp"
cp tests/NativeTests.cpp "$tmp/NativeTests.cpp"
sed -i 's|"../src/yatzy.hpp"|"yatzy.hpp"|' "$tmp/NativeTests.cpp"
g++ -std=c++20 -Wall -Wextra -pedantic "$tmp/NativeTests.cpp" -o "$tmp/red"
if "$tmp/red" > "$tmp/red.log" 2>&1; then echo 'RED UNEXPECTED PASS'; exit 1; fi
if ! grep -q 'assertion 1:' "$tmp/red.log"; then cat "$tmp/red.log"; echo 'RED did not fail by behavior'; exit 1; fi
echo 'RED C++20 compiled, failed behaviorally at assertion 1'
g++ -std=c++20 -O2 -Wall -Wextra -pedantic tests/NativeTests.cpp -o "$tmp/green"
"$tmp/green"
g++ -std=c++20 -O2 -Wall -Wextra -pedantic src/main.cpp -o "$tmp/yatzy"
go run tests/oracle.go "$tmp/yatzy"
python3 tests/mutations.py
go vet tests/oracle.go
