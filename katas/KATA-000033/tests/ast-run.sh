#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
echo '=== TypeScript original RED/GREEN ==='
tsc -p tsconfig.json
node build/tests/test_forth.js
python3 tests/differential.py
# Deliberately wrong but compilable RED variant: behavior must fail.
red="$(mktemp -d)"; trap 'rm -rf "$red"' EXIT
mkdir -p "$red/src" "$red/tests"
cat >"$red/src/forth.ts" <<'RED'
export class ForthError extends Error {}
export class Forth { evaluate(_source: string): number[] { return []; } }
export function evaluateProgram(_source: string): number[] { return []; }
RED
cp tests/test_forth.ts "$red/tests/test_forth.ts"
tsc --strict --target ES2022 --module commonjs --lib ES2022,DOM --outDir "$red/build" "$red/src/forth.ts" "$red/tests/test_forth.ts"
if node "$red/build/tests/test_forth.js" >"$red/red.log" 2>&1; then echo 'FAIL: RED variant unexpectedly passed' >&2; exit 1; fi
grep -q 'ASSERT behavior' "$red/red.log"
echo 'PASS: compiled RED fails behaviorally'
echo '=== Go AST-first independent oracle ==='
go vet tests/ast_oracle.go
go run tests/ast_oracle.go
# Compile three semantic mutants of the original production source, then prove
# that the independent Go model rejects all in their own isolated workspaces.
for mutant in floor_division builtin_precedence frozen_alias_truncation; do
  mkdir -p "$red/$mutant/src" "$red/$mutant/tests"
  cp src/forth.ts "$red/$mutant/src/forth.ts"
  cp cli.js "$red/$mutant/cli.js"
  cp tests/test_forth.ts "$red/$mutant/tests/test_forth.ts"
  case "$mutant" in
    floor_division) sed -i 's/Math.trunc(a \/ b)/Math.floor(a \/ b)/' "$red/$mutant/src/forth.ts" ;;
    builtin_precedence) sed -i 's/if (definition) return \[...definition\];/if (definition \&\& !operations.has(token as Primitive)) return [...definition];/' "$red/$mutant/src/forth.ts" ;;
    frozen_alias_truncation) sed -i 's/body.push(...this.resolve(tokens\[i++\]));/body.push(...this.resolve(tokens[i++]).slice(0,1));/' "$red/$mutant/src/forth.ts" ;;
  esac
  tsc --strict --target ES2022 --module commonjs --lib ES2022,DOM --rootDir "$red/$mutant" --outDir "$red/$mutant/build" "$red/$mutant/src/forth.ts" "$red/$mutant/tests/test_forth.ts"
  if (cd "$red/$mutant" && go run "$OLDPWD/tests/ast_oracle.go") >"$red/$mutant.log" 2>&1; then
    echo "FAIL: mutant $mutant escaped oracle" >&2; exit 1
  fi
  grep -q 'FAIL case' "$red/$mutant.log"
  echo "PASS: compiled mutant $mutant detected by AST oracle"
done
echo 'PASS: Forth hardening complete'
