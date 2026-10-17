# KATA-000033 — Forth interpreter in TypeScript

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/forth
Exercism's problem-specifications repository is MIT licensed. This kata is an independently implemented stack-language evaluator under the root Katas MIT license. No Exercism canonical-data, starter source or tests have been copied.

## Contract

Whitespace-delimited integer literals (including negatives), integer arithmetic (+, -, *, / with truncation toward zero), stack manipulation (DUP, DROP, SWAP, OVER) and case-insensitive user definitions `: name words ;`. Underflow, unknown words, division by zero, missing semicolon, invalid numeric names and unsafe integer ranges raise explicit errors. The evaluator retains its stack and dictionary across calls; evaluateProgram creates an isolated interpreter for one script.

Definitions **freeze dependencies when declared**: redefining a builtin or another word later does not change an already compiled word. Earlier versions can be used during redefinition. Unlike the complete Forth language, this subset does not support loops, control-flow, I/O or unbounded BigInt arithmetic. Safe JS integers limit magnitude to ±(2^53−1), comfortably above the signed 16-bit minimum of the exercise.

## Language decision

TypeScript expresses tagged bytecode, map-based symbol bindings, typed stack contracts and a deterministic interpreter. JavaScript/TS belongs to Genkidama; Scala/Rust would be viable but do not offer better local testability for this lexical/VM exercise. An independently authored Python reference instead interprets expanded tokens (not tagged TS instructions) over 816 generated and fixed programs.

## Reproduce locally

~~~bash
cd katas/KATA-000033
tsc -p tsconfig.json
node build/tests/test_forth.js
python3 tests/differential.py
mkdir -p /tmp/forth-red/src /tmp/forth-red/tests
cp tests/forth_red.ts /tmp/forth-red/src/forth.ts
cp tests/test_forth.ts /tmp/forth-red/tests/test_forth.ts
tsc --strict --target ES2022 --module commonjs --lib ES2022,DOM --outDir /tmp/forth-red/build /tmp/forth-red/src/forth.ts /tmp/forth-red/tests/test_forth.ts
if node /tmp/forth-red/build/tests/test_forth.js >/tmp/forth-red.log 2>&1; then exit 1; fi
grep -q 'ASSERT behavior' /tmp/forth-red.log
~~~

Local Node 22 and tsc verified 23 fixed cases and 816 Python differential programs, including error scenarios. The intentionally wrong RED stub compiles and produces a behavioral mismatch. Run GitHub Actions to confirm exact-head results before changing status to verified; a reviewed merge and publication record are required for published.

Author-provisional difficulty 5/5 and score 91/100 (transfer 19, technical depth 19, oracle 15, TDD 14, novelty 8, pedagogy 9, portability 4, maintenance 3), not independent calibrated rankings.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md)
