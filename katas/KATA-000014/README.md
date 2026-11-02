# KATA-000014 — Configure Wardrobe: Swift DP + Go count-vector oracle

**State:** GREEN and development-complete **locally only** (2026-10-30); NOT remotely certified, verified, or published. `dev` still records `discovered`. Original `dev` HEAD at start: `0d97c338cb8702265ad6fda4381cbd9336197f61`; catalog blob `9e303fc1eb0fe964d84e10fb85b19e43148ca4ee`. These are historical checkpoints, not a source of truth for later runs.

## Domain and invariants

The [Kata-Log Configure Wardrobe challenge](https://kata-log.rocks/configure-wardrobe-kata) asks for every unordered combination of wardrobe units of widths **50, 75, 100, 120 cm** exactly filling a **250 cm** wall, then the cheapest combination using respective prices **59, 62, 90, 111 USD**. We additionally support wall widths **0..1000 cm**, as an explicit local extension. Order of elements does not matter; count vectors are unique and sorted lexicographically by counts in ascending-width order. A valid plan satisfies `sum(width[i] * count[i]) == wall`, `count[i] >= 0`, and `price == sum(price[i] * count[i])`. For an empty wall there is one zero-count plan costing zero. If no plan exists, cheapest is absent. For equal prices the lexicographically smallest vector wins. This is not a configurable-width optimizer; widths and prices are fixed by the original task.

Expected 250cm vectors in sorted order: `(0,2,1,0) $214`, `(1,0,2,0) $239`, `(2,2,0,0) $242`, `(3,0,1,0) $267`, `(5,0,0,0) $295`. The cheapest uses two 75cm units and one 100cm unit ($214). The CLI `wardrobe WALL` prints a `COUNT`, sorted `PLAN counts PRICE total` records, then `CHEAPEST ...` or `CHEAPEST NONE`. It rejects wrong arity, non-ASCII decimal characters, signed/fractional values, overflow and widths >1000 with exit code 2. Leading ASCII zeros are accepted. This CLI is original to the experiment, not part of Kata-Log's statement.

## License and per-artifact rights

The *concept, fixed widths and price table* were read from Kata-Log's own page, which explicitly states its own contents are **public domain**: https://kata-log.rocks/configure-wardrobe-kata . No linked third-party starter, fixture, code, diagram or image was imported; those linked repositories have separate rights. All Swift implementation/tests, Go oracle, Python mutation orchestrator, CI and documentation here are independently authored for Katas under its **MIT** license. Catalog fingerprint `wardrobe-configuration-combinatorics` is preserved. Source license identifier `Unlicense` refers only to Kata-Log's own content, not to third-party links.

## Language selection BEFORE workflow inspection

This is an integer partition / constrained combination enumeration problem with exact arithmetic, uniqueness, ordering and cost minimization. Compared **Swift 6.2**, **Julia**, **Prolog**, and **Haskell** before consulting existing CI. Julia would make numerical constraint exploration natural, but was unavailable locally for authentic RED/GREEN; Prolog's relational search would elegantly express the Diophantine equation but was unavailable locally; Haskell could express a lazy list-comprehension solution with strong types but GHC was unavailable. **Swift** was selected for an idiomatic immutable `WardrobePlan`, typed count vectors, explicit integer bounds, and a memoized suffix-state dynamic program that exposes a different engineering trade-off from direct relational search. This choice does not imply Swift is mathematically optimal, and was not selected for an existing workflow or a language quota. After the choice, consulted Genkidama `ChicoDotNet/Genkidama` `dev` `.github/workflows/polyglot.yml` Swift family and Katas Swift 6.2 / Go 1.23.2 workflow; proposed a dedicated ubuntu-24.04 CI workflow.

## Separate implementation, tests, and oracle decisions

| Responsibility | Language | Algorithm / technique | Independent fault detection |
| --- | --- | --- | --- |
| Implementation | Swift 6.2 | Recursive suffix-state **dynamic programming** memoized by `(moduleIndex, remainingWidth)`, producing immutable plan values | State boundary, count vector and price errors |
| RED/GREEN | Swift 6.2 native executable | Compilable intentionally incorrect empty-plan stub, then **5,034** native assertions including all 0..1000 wall invariants | Regression and invalid input handling |
| Oracle | **Go 1.23.2** | **Brute-force enumeration of physical count vectors** using nested loops, arithmetic remainder for 120cm and independent pricing | DP cache/state, missing combinations, duplicate combinations, wrong price, tie-breaking |
| Metamorphisms | Go invoking real Swift CLI | Every plan for `wall` maps injectively to a plan for `wall+50` by adding one 50cm unit; optimal price cannot exceed previous optimum +59; leading-zero wall representation invariant | Completeness and CLI representation |
| Mutation gate | Python only as orchestrator; actual Swift compiler + Go oracle | Three compiled, behaviorally wrong variants: 75cm price, 120cm width, accepting incomplete suffix | Sensitivity without Python expected-value model |

**Two strategies compared:** a second recursive DP implementation in another language versus brute-force count vectors with arithmetic divisibility. The second DP could share missing-branch/cache bugs; Go count-vector enumeration uses no recursion or memoization and independently derives the last count from the remainder. Both still share the same width/price table and source interpretation; neither proves the spec itself. Metamorphic injection adds a different relational property. No solver or Python reference was used. Complexity is intentionally bounded to walls 0..1000; exhaustive Go checks cover all allowed CLI walls, but cannot prove unbounded correctness.

## Real execution

```bash
cd katas/KATA-000014
bash tests/run.sh
```

Local Linux x86_64: Swift **6.2.1**, Go **1.23.2**, Python **3.13.5**. RED compiles and fails on its intended first behavioral assertion; GREEN **5,034 assertions**; Go oracle **1,001 real Swift process invocations**, **1,482 50cm-injection metamorphic plan checks**, **120 leading-zero metamorphic CLI invocations**, **15 malformed-CLI rejections**; `go vet` passes; **3/3 compiled Swift mutants rejected by actual Go behavioral mismatches**. `swiftc -swift-version 6 -warnings-as-errors` used. Logs and exact commands in `evidence/local-run.txt`. No remote CI or independent review at this checkpoint.

**Retrabajo:** strict Swift 6 concurrency checking rejected `stderr` access in tests and CLI; replaced with `FileHandle.standardError` before rerunning all gates. The mutation orchestrator initially compared bytes against decoded text and failed with a Python `TypeError`; fixed the harness, then reran all three actual compiler-and-oracle mutation gates. Neither harness failure was misreported as a product mutation kill.

## Ninja v0.1.29 review

Decision **no_change**. This local exercise supports the general usefulness of a structurally different reference model but does not establish that Ninja caused better outcomes. The known limits are shared constants, bounded wall size, and a single authored exercise. No new principles, migrations, holdout promotion, or 0.16% scale-up are justified. Before publication: integrate on a reviewable branch, run exact-head CI, obtain independent review, squash-merge into `dev`, and verify the live catalog and post-merge SHA.

## 2026-10-30 adversarial oracle audit (later checkpoint)

The first Go oracle broke ties by comparing `key(counts)` as a string. This is not a valid numeric lexicographic ordering once counts reach two digits (`"10,0,0,0" < "2,0,0,0"` as strings). No equal-minimum-price ties occur with the fixed prices in the tested 0..1000cm domain, so the original 1,001-wall differential run could not expose this latent defect. The independent oracle now uses a numeric count-vector comparator, with an explicit synthetic two-digit regression. Re-executed `go vet tests/oracle.go`, compiled the Swift executable with Swift 6.2.1, executed `go run tests/oracle.go .build/wardrobe` (1,001 walls, 1,482 injection checks, 120 padded inputs, 15 invalid cases), and re-executed `python3 tests/mutations.py` (3/3 compiled and killed). The full `tests/run.sh` invocation exceeded the local command timeout after RED, GREEN and Go oracle had already succeeded; mutation gate was then executed separately and passed. No remote CI or independent review is claimed.
