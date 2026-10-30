# KATA-000025 — String Calculator: Swift Unicode lexer, Go AST-first oracle

**Status:** locally GREEN and development complete, **not remotely certified, verified, or published**. `dev` still records `discovered`; update metadata only on a reviewable branch after reconciling the live catalog. Local checkpoint 2026-10-30; source `dev` HEAD at start `0d97c338cb8702265ad6fda4381cbd9336197f61`, catalog blob `9e303fc1eb0fe964d84e10fb85b19e43148ca4ee`. Do not treat these as permanent.

## Domain, contract and edge cases

A string encodes nonnegative and negative integers separated by comma/newline or by an optional custom delimiter header. Empty input is zero; custom single-character header `//;\n` or bracketed, nonempty delimiter list `//[**][%]\n` replaces defaults. Delimiters are **literal Unicode grapheme sequences**, not regex; longest-match handles overlapping delimiters. Values over 1000 are ignored, including arbitrarily long positive digit strings; 1000 is included. Every negative is rejected with an ordered list of values. All tokens are validated before returning the sum. Reject empty tokens, malformed numbers, malformed headers and negative magnitudes outside Int64. Sum is checked for Int64 overflow.

The original nine incremental Kata-Log steps are the conceptual target. Additional local strictness (malformed input rejection, reserved numeric/`-` delimiters, longest-match tie breaking, Unicode grapheme matching, explicit error codes, and Int64 overflow) is a **documented project extension**, not claimed to be specified upstream. In particular, custom delimiters replace comma/newline; bracket characters and digits are forbidden inside custom delimiters. An empty body after a header is invalid. Input is read as Base64 UTF-8 lines, output is `OK|integer` or `ERR|code|base64(message)`; this transport is original and not part of the upstream kata.

## Per-artifact rights and provenance

Only the **concept** is taken from Kata-Log's own public-domain page: https://kata-log.rocks/string-calculator-kata ; its site's public-domain statement: https://kata-log.rocks/ . No linked GitHub starter, tests, fixtures, datasets, images or reference implementation were copied. All Swift code, Swift tests, Go oracle, mutation runner, workflow and README were authored locally for this repository under its MIT license. The original author is credited by the source page (Roy Osherove). The site declaration does **not** grant rights to third-party linked code. Fingerprint preserved: `custom-delimiter-parser-negative-validation`.

## Language selection BEFORE workflow inspection

The core risk is ambiguous delimiter tokenization, Unicode semantics, negative aggregation, and strict input validation. Compared **Swift 6.2**, **OCaml**, **Haskell**, and **Go**. Swift's `Character` grapheme clusters, expressive enums for typed errors, and explicit checked `Int64` operations make a useful parser experiment; it exposes a distinctive contrast to byte-oriented tokenizers. OCaml would express parser combinators and ADTs elegantly, but native OCaml was unavailable locally; Haskell's parser combinators and purity would be educational but native GHC was unavailable. Go would make a simple byte scanner and subprocess reference, but would not illuminate Swift grapheme semantics. This is an affinity decision, not a language quota or CI-convenience decision. **After** selecting Swift, consulted Genkidama `ChicoDotNet/Genkidama` `dev` `eng/ci/registry.json` blob `24bde39c748dd3903789fd20eace80894a4735fb`, and the existing Katas Swift/Go setup; proposed Ubuntu 24.04 Swift 6.2 / Go 1.23.2 workflow.

## Independent selection of tests and oracle

| Role | Language | Strategy | What it catches |
| --- | --- | --- | --- |
| Production | Swift 6.2 | Unicode `Character` scanner; longest literal delimiter first; typed errors; checked integer sum | Parser and error semantics |
| RED/GREEN | Swift 6.2 | Compilable wrong stub + 30 hand-authored behavioral assertions | Regressions, invalid tokens, overlapping delimiters, huge integers, Unicode |
| Independent oracle | Go 1.23.2 | **AST-first** generated integer leaves, then serialize using one of seven delimiter grammars; expected result from leaves, not parsing serialized text | Scanner/splitting, token boundary, wrong threshold, ordering, missing negative checks |
| Metamorphic | Go invoking real Swift executable | Reorder nonnegative AST leaves and relabel delimiter grammar, compare actual outputs | Dependence on ordering/delimiter choice |
| Mutations | Python orchestration + genuine Swift compilation | Wrong 1000 threshold, shortest-first delimiters, ignore negatives; native tests must kill all | Test sensitivity, not a second oracle |

Compared **reference parser** vs **AST-first generator**. A second parser in Go would risk sharing the same split/precedence logic; generating an AST and serializing it reverses the dependency, making boundary defects visible. This oracle shares numeric and delimiter contract assumptions and deterministic seeds; it is not a formal proof. The malformed-input cases are a small independent hand-authored table, not generated from the AST. Python computes no expected answers.

## Actual execution and limits

```sh
cd katas/KATA-000025
bash tests/run.sh
```

Local Linux x86_64: Swift **6.2.1**, Go **1.23.2**, Python **3.13.5**. RED compiled and failed on a behavioral sum assertion (exit 1); GREEN **30 native assertions**; Go oracle **2,948 real Swift requests** = 343 exhaustive three-number ASTs + 1,800 seeded random ASTs + 800 metamorphic executions + five invalid/edge cases; `go vet` passed; **3/3 compiled Swift mutants detected**. `swiftc -swift-version 6 -warnings-as-errors` used. Logs `evidence/full-local.txt`, `evidence/red.txt`, `evidence/green.txt`. No CI executed for this checkpoint; `.github/workflows/swift-string-calculator-kata.yml` is a proposal. Do not mark `verified` or `published` before exact-head CI, independent review, squash merge and post-merge reconciliation.

**Retrabajo:** strict Swift 6 concurrency checking rejected a mutable static test counter; fixed with `@MainActor`. A subsequent edge-case audit found long leading-zero positive numbers incorrectly rejected; normalized significant digits before parsing, added regression and reran all gates. No production starter was used.

## Ninja review

Ninja **v0.1.29**, `no_change`. OBS-004 (characterization before refactor) and OBS-001 (independent model) are compatible with AST-first tests but do not establish a transferable causal benefit. A single parser kata cannot validate general improvement. No skill changes; no holdout/scale-up before 90 published. Next mandatory release to `main` at 36 newly published.
