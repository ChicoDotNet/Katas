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

## 2026-10-28 — AST-first Go oracle and frozen-binding hardening (PR pending)

**Domain and invariants.** This bounded Forth subset compiles definitions to frozen
instructions, executes integer arithmetic with truncation toward zero, supports
case-insensitive names and primitive shadowing, and rejects malformed programs.
An interpreter that resolves aliases dynamically can pass arithmetic examples
while changing behavior after redefinition. Incorrect negative division can
survive positive-only tests.

**Language decision before CI.** The published implementation stays **TypeScript**:
tagged bytecode, compiled instructions and a symbol table make its VM semantics
explicit. **Haskell** offers algebraic data types and pure interpretation, but
would not expose the same JavaScript numeric and runtime name-shadowing risks.
**OCaml** also expresses bytecode strongly; replacing the published interpreter
without a demonstrated gain would require unnecessary recertification. Java,
Python or Go as production would obscure this VM-specific learning.

**Independent language roles.** Production and native RED/GREEN: TypeScript 5.8.3
on Node 22. Existing differential oracle: Python 3 token interpreter.
New oracle: **Go 1.23.2**, selected for explicit immutable expression trees,
deterministic generation and bounded integer arithmetic. Ruby could model
trees concisely but its numeric division semantics require extra precautions;
Haskell would add a toolchain without an additional detector for this scope.

**Two structurally different reference strategies.** The original Python
reference interprets tokens and expands definitions; it risks sharing lexical
and stack-machine assumptions with TypeScript. The Go oracle builds an
expression **AST first**, recursively evaluates the expected result, and only
then emits postfix Forth. It never parses Forth or replays the instruction VM.
Additional metamorphic witnesses check direct expressions, compiled words,
composition, frozen aliases, self-redefinition, primitive shadowing and
invalid inputs. Fixed negative-division witnesses anchor shared assumptions.

**Shared-error risks and limits.** The generator uses 300 seeded AST pairs,
intermediate magnitudes bounded to ±1,000,000 and a finite subset of Forth.
It cannot establish full language correctness or arbitrary safe-integer
behavior; the existing native tests address overflow and unsafe literals.
Frozen-alias expectations are part of this kata's documented contract, not
claims about every Forth implementation. Seed: 20261028.

**Reproduction.** From this kata directory:

~~~bash
node --version       # v22.16.0
tsc --version        # 5.8.3
go version           # go1.23.2 linux/amd64
python3 --version    # 3.13.5
bash tests/ast-run.sh
~~~

On 2026-10-28 the full script passed locally: 23 fixed native TypeScript
tests, 816 existing Python differential programs, a compiled behaviorally
failing RED stub, **2,117 Go AST-first witnesses** (2,100 generated + 17
fixed), go vet and **3 compiled semantic mutants** rejected by the oracle:
floor vs truncating division, builtin precedence over user shadowing, and
truncated frozen-definition expansion. See
[evidence/ast-local-2026-10-28.txt](evidence/ast-local-2026-10-28.txt) and
[evidence/ast-skill-review-2026-10-28.md](evidence/ast-skill-review-2026-10-28.md).

**Rights and governance.** The source is an independently authored MIT
implementation of the Exercism MIT-licensed problem-specifications concept;
no upstream starters, canonical fixtures or third-party code imported.
Ninja v0.1.29 review is confirmed locally, not a causal claim. The new
workflow `.github/workflows/typescript-forth-ast-hardening.yml` uses the
Genkidama TypeScript/Go runtime families. CI for this PR and independent
review must succeed on the exact head before merge. This hardening leaves
the published implementation and catalog status unchanged, and counts as
**zero new published katas**.
