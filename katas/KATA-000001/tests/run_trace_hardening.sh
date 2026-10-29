#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/red" "$tmp/green"
javac --release 21 -d "$tmp/red" src/TriviaCli.java src/TriviaLegacy.java tests/RedStub.java tests/TestTrivia.java
if (cd "$PWD" && java -cp "$tmp/red" TestTrivia > "$tmp/red.log" 2>&1); then
  echo 'FAIL: RED stub unexpectedly passed' >&2; exit 1
fi
grep -q 'refactored behavioral golden master mismatch' "$tmp/red.log"
echo 'PASS: compilable behavioral RED'
javac --release 21 -d "$tmp/green" src/*.java tests/TestTrivia.java
java -cp "$tmp/green" TestTrivia
TRIVIA_CASES=0 ruby tests/trace_contract.rb "$tmp/green"
# Mutation controls are expected to fail *behaviorally* after successful javac.
python3 - "$tmp" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1]); original = Path('src/TriviaRefactored.java').read_text()
mutants = {
 'turn-rotation': ('current = (current + 1) % players.size()', 'current = (current + 2) % players.size()'),
 'question-sequence': ('++questions[category]', '(++questions[category] + 1)'),
 'score-reset': ('new Participant(name, newStation, stars, false)', 'new Participant(name, newStation, 0, false)'),
}
for name, (needle, replacement) in mutants.items():
    assert original.count(needle) == 1, (name, 'missing unique mutation site')
    folder = root / name; folder.mkdir()
    (folder / 'TriviaRefactored.java').write_text(original.replace(needle, replacement))
PY
for mutant in turn-rotation question-sequence score-reset; do
  mkdir -p "$tmp/$mutant/classes"
  javac --release 21 -d "$tmp/$mutant/classes" src/TriviaCli.java src/TriviaLegacy.java "$tmp/$mutant/TriviaRefactored.java"
  if TRIVIA_MODES=refactored TRIVIA_CASES=0 ruby tests/trace_contract.rb "$tmp/$mutant/classes" > "$tmp/$mutant.log" 2>&1; then
    echo "FAIL: undetected $mutant" >&2; exit 1
  fi
  grep -q 'TRACE CONTRACT FAILURE' "$tmp/$mutant.log"
  echo "PASS: compiled mutant detected: $mutant"
done
