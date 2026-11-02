#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/green" "$WORK/red"
cp "$ROOT"/src/*.ad? "$WORK/green/"
cp "$ROOT/tests/test_game.adb" "$WORK/green/"
cp "$ROOT"/src/*.ad? "$WORK/red/"
cp "$ROOT/tests/test_game.adb" "$WORK/red/"
# Deliberately wrong but syntactically valid implementation, not a missing symbol.
sed -i 's/State.Scores (P) := State.Scores (P) + 1;/State.Scores (P) := State.Scores (P);/' "$WORK/red/bug_proof_game.adb"
(cd "$WORK/red" && gnatmake -q -gnat2022 -gnato -o test_game test_game.adb)
if "$WORK/red/test_game" > "$WORK/red.out" 2>&1; then
  echo 'RED unexpectedly passed'; exit 1
fi
grep -q 'FAIL behavioral' "$WORK/red.out"
echo 'RED compiled and failed behaviorally'
(cd "$WORK/green" && gnatmake -q -gnat2022 -gnato -o test_game test_game.adb && gnatmake -q -gnat2022 -gnato -o cli cli.adb)
"$WORK/green/test_game"
go vet "$ROOT/tests/oracle.go" "$ROOT/tests/oracle_test.go"
go test "$ROOT/tests/oracle.go" "$ROOT/tests/oracle_test.go"
go build -o "$WORK/oracle" "$ROOT/tests/oracle.go"
"$WORK/oracle" "$WORK/green/cli"
for kind in wrong-score wrong-deck wrong-release; do
  mkdir -p "$WORK/$kind"
  cp "$ROOT"/src/*.ad? "$WORK/$kind/"
  case "$kind" in
    wrong-score) sed -i 's/State.Scores (P) := State.Scores (P) + 1;/State.Scores (P) := State.Scores (P);/' "$WORK/$kind/bug_proof_game.adb";;
    wrong-deck) sed -i 's/Q := Positive ((State.Visits (C) mod Natural (State.Decks (C))) + 1);/Q := 1;/' "$WORK/$kind/bug_proof_game.adb";;
    wrong-release) sed -i 's/State.Penalties (P) := False;/State.Penalties (P) := True;/' "$WORK/$kind/bug_proof_game.adb";;
  esac
  (cd "$WORK/$kind" && gnatmake -q -gnat2022 -gnato -o cli cli.adb)
  if "$WORK/oracle" "$WORK/$kind/cli" > "$WORK/$kind.out" 2>&1; then
    echo "MUTANT SURVIVED: $kind"; exit 1
  fi
  grep -Eq 'mismatch|invalid input accepted' "$WORK/$kind.out"
  echo "MUTANT $kind compiled and was behaviorally rejected"
done
echo 'MUTANTS PASS 3/3'
