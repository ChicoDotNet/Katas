#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
swiftc -swift-version 6 src/Search.swift tests/TestSearch.swift -o "$tmp/native"
"$tmp/native"
swiftc -swift-version 6 -O src/Search.swift src/Main.swift -o "$tmp/cli"
go vet tests/geometry_oracle.go
go build -o "$tmp/oracle" tests/geometry_oracle.go
"$tmp/oracle" "$tmp/cli"
swiftc -swift-version 6 -D KATA_RED src/Search.swift tests/TestSearch.swift -o "$tmp/red"
if "$tmp/red" >"$tmp/red.log" 2>&1; then echo 'FAIL: RED unexpectedly passed' >&2; exit 1; fi
grep -q 'FAIL behavioral assertion' "$tmp/red.log"
python3 - "$tmp" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1]); source = Path('src/Search.swift').read_text()
mutants = {
    'missing-diagonal': ('(-1,1)', '(-1,0)'),
    'incorrect-endpoint': ('end: [lastR,lastC]', 'end: [r,c]'),
}
for name, (old, new) in mutants.items():
    if source.count(old) != 1:
        raise SystemExit(f'FAIL: mutation anchor {name} not unique')
    (root / f'{name}.swift').write_text(source.replace(old, new, 1))
PY
for name in missing-diagonal incorrect-endpoint; do
  swiftc -swift-version 6 -O "$tmp/$name.swift" src/Main.swift -o "$tmp/$name"
  if "$tmp/oracle" "$tmp/$name" >"$tmp/$name.log" 2>&1; then
    echo "FAIL: undetected mutant $name" >&2; exit 1
  fi
  grep -q 'FAIL geometry oracle' "$tmp/$name.log"
  echo "PASS: compiled and detected mutant $name"
done
echo 'PASS: native Swift, constructive Go oracle, RED, and 2 mutation gates'
