#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc -swift-version 6 -O src/leaderboard.swift src/cli.swift -o "$work/leaderboard"
go vet tests/histogram_oracle.go
go run tests/histogram_oracle.go "$work/leaderboard"
# Two independently compiled production mutants must be killed by the same oracle.
for mutation in points tie; do
  case "$mutation" in
    points) sed 's/25,18,15,12,10,8,6,4,2,1/25,19,15,12,10,8,6,4,2,1/' src/leaderboard.swift > "$work/leaderboard.swift" ;;
    tie) sed 's/left.driver < right.driver/left.driver > right.driver/' src/leaderboard.swift > "$work/leaderboard.swift" ;;
  esac
  swiftc -swift-version 6 -O "$work/leaderboard.swift" src/cli.swift -o "$work/mutant"
  if go run tests/histogram_oracle.go "$work/mutant" >"$work/mutant.log" 2>&1; then
    echo "FAIL: mutant $mutation survived" >&2; exit 1
  fi
  grep -q 'FAIL histogram/metamorphic:' "$work/mutant.log"
  echo "PASS: compiled $mutation mutant detected"
done
