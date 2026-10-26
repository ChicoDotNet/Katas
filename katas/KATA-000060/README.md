# KATA-000060 — Fixed-string grep (Perl 5 / Go)

**Locally GREEN only; remote certification pending.** This kata already exists as discovered in the catalog. The proposed catalog transition is `green` with `development_complete: true`, never `verified` or `published` without exact-head CI, review and squash merge. The previous published count in README files is not a live metric.

## Rights and scope

Conceptual source: Exercism problem-specifications, [grep](https://github.com/exercism/problem-specifications/tree/main/exercises/grep), MIT ([license](https://github.com/exercism/problem-specifications/blob/main/LICENSE)). Source code, tests, generated fixtures, Go reference models, mutation driver and documentation are original MIT material. No upstream starter, canonical-data.json or fixtures were copied. This is an implementation exercise, not an upstream refactor.

## Domain and invariants

Run `perl src/grep.pl [flags...] [--] PATTERN FILE...`. Supported flags: `-n` line numbers, `-l` filenames only (overrides `-n`), `-i` ASCII-only case-insensitive matching, `-v` invert and `-x` exact-line matching. The terminator `--` permits a literal pattern starting with a dash. The default match is a **literal substring** (not a regular expression). Output preserves input file order and repeated filenames, prefixes filenames when multiple operands are present, and places line numbers after any filename. Empty pattern matches every line; exact empty pattern matches only empty lines. A final line without LF is included. UTF-8 arguments are decoded explicitly; files are decoded as UTF-8 and processed incrementally.

Invalid flags, missing/unreadable paths and invalid UTF-8 arguments produce exit 2. File preflight avoids partial stdout for missing paths. Binary files, full Unicode casefold, symlink races, permission TOCTOU and arbitrary regex are outside this adapted contract.

## Language decision before looking at CI

Compared **Perl 5.40**, **Rust**, **Go**, **OCaml** against streaming text, fixed-pattern search, option precedence, literal metacharacters, UTF-8 argv and output order. Perl wins for its distinctive text-processing idioms and the important difference between `index` literal matching and regex semantics, plus the real `@ARGV` decoding trap. Rust emphasizes ownership and buffered I/O; Go is simple but less instructive here and is already the oracle language; OCaml makes flag modeling expressive but less revealing for the text-streaming challenge. Counterfactual: choosing a familiar Go/Python/Java CLI by workflow convenience would conceal the Perl-specific bug actually found. Only **after** this choice was Genkidama's scripting family and its CI registry consulted. No artificial language quota.

## Implementation / tests / oracle matrix

| Role | Language | Technique |
| --- | --- | --- |
| Implementation | Perl 5.40.1 | Streaming readline; fixed substring via index; explicit argv decoding; flag precedence |
| RED/GREEN | Perl 5.40.1, Test::More | Compilable always-empty stub fails behaviorally; 38 GREEN assertions in 19 cases |
| Oracle A | Go 1.23.2 | strings.Contains and exact equality on deterministic generated fixtures |
| Oracle B | Go 1.23.2 | regexp.QuoteMeta + RE2 (different matching engine) |
| Metamorphic | Go 1.23.2 | 200 numbered normal/inverted pairs partition line indices |
| Oracle self-test | Go 1.23.2 | 16 semantic cases; go test -race |
| Mutation driver | Python 3 | Orchestration only; seven syntax-valid Perl mutations rejected by native and Go checks |

**Two structural verification strategies compared:** independent literal matching and quoted-regex matching; complement metamorphism provides a third, algebraic check. The two Go models share output formatting, flags and ASCII-fold conventions, so they are not fully independent. Two translations of the same algorithm would be weaker than distinct engines/properties. Self-tests and targeted mutants reduce, but cannot eliminate, shared-assumption risk. No independent human holdout was performed.

## Reproduction and measured results

```bash
cd katas/KATA-000060
bash tests/run.sh
# perl -c tests/red_stub.pl; native RED expected behavioral failure
# perl -c src/grep.pl; perl tests/native.t: 38 assertions PASS
# go vet tests/oracle.go tests/oracle_test.go
# go test -race tests/oracle.go tests/oracle_test.go: PASS
# go build -o build/grep-oracle tests/oracle.go
# build/grep-oracle: 900 deterministic cases, 1800 matcher checks,
#   200 complement pairs, one witness: PASS
# python3 tests/mutations.py: 7/7 syntax-valid mutants detected by
#   both native tests and Go oracle (240 cases per mutant): PASS
```

Genuine local execution was repeated on **2026-10-26** with Perl 5.40.1, Go 1.23.2 and Python 3.13.5; full run exited 0. First attempt exceeded the execution window during a cold Go build; retry with warmed cache passed. No claim is made that this equals CI. The RED failure was behavioral, not a compilation error.

**Retrabajo:** differential testing found `café` argv bytes not decoded into Perl text; explicit `Encode::decode` corrected it. Separate RED found `-- -x` wrongly rejected; parsing now tracks the terminator. The mutation driver previously failed to forward `KATA_ORACLE_CASES` to Go, multiplying execution; it now forwards the environment and imposes a 45-second child timeout. Seven mutants are rejected by both suites. No causal improvement of Ninja is claimed without active-time, retrabajo and independent evaluation.

## Governance and limitations

Candidate `KATA-000060` retains original Exercism fingerprint and discovery scan. No new scan, language migration or new published kata is claimed. Ninja v0.1.29 was reviewed as `confirmed` without modifying the skill. CI must execute the **exact PR HEAD** with all relevant gates successful, followed by review, squash merge into dev and post-merge catalog/HEAD reconciliation. The four earlier GREEN publication candidates are handled separately in PR #45. Main promotion milestone remains 36 published, independent pilot gate 90. This README records decisions and commands, not a live catalog snapshot.
