# KATA-000051 — Spiral Matrix (Fortran + Go)

**Status:** GREEN development-complete on reviewable feature branch, **NOT published or remotely certified** until exact-head CI, review and squash merge. Original local checkpoint 2026-10-26; reconciled with dev 0d97c338cb8702265ad6fda4381cbd9336197f61 before branch creation.

## Contract and invariants

Generate a square n-by-n matrix containing every integer 1..n² exactly once, clockwise inward from the upper left. n=0 yields empty output; n=1 yields 1; unsupported n<0 or n>512 is rejected. O(n²) time and memory, allocatable 2D Fortran grid(row,col) with column-major layout. Explicit shrinking boundaries ensure each ring is visited exactly once.

## Artifact-level provenance and rights

Concept only: Exercism problem-specifications spiral-matrix instructions (MIT), blob 01e8a77f808ebf669389df96d5a86ae06cc23f69, at https://github.com/exercism/problem-specifications/blob/main/exercises/spiral-matrix/instructions.md. MIT license blob 6813d6298df9a46da6485050e8a5fcd61ab79879 at https://github.com/exercism/problem-specifications/blob/main/LICENSE. No starter, upstream tests, fixture data or canonical source copied. This kata's Fortran, Go, Python, shell and sample assertions are original code under the Katas MIT license. Retain the conceptual attribution; the original specification is not reproduced.

## Implementation choice before checking workflows

Compared Fortran, Julia, Rust and Go. Fortran is particularly instructive here: human row-wise clockwise traversal mapped onto a genuine column-major allocatable 2D array; indexing and boundary invariants remain explicit. Julia shares column-major semantics but obscures some lower-level allocation decisions; Rust emphasizes ownership of a row-major representation; Go is conventional and offers less distinctive learning for the implementation. No language quotas and no pre-existing CI preference.

## Three independent language decisions and oracle techniques

| Role | Language | Algorithm and reason |
| --- | --- | --- |
| Production | Fortran 2008 subset / GNU Fortran 14.2 | Shrinking boundary traversal with 64-bit cells |
| RED/GREEN | Native Fortran assertions, real gfortran, -fcheck=all | Compilable all-zero stub fails behaviorally; exact small matrices and 74,127 assertions through size 60 |
| Independent model A | Go 1.23.2 | Closed-form ring index arithmetic (minimum border distance), not a translated walker |
| Independent model B | Go 1.23.2 | Metamorphic ring peeling: compare two *separately executed* sizes n and n-2, with additive outer-ring offset |
| Structural checks | Go | Parse output, check permutation of 1..n² and reject malformed grids |
| Mutation control | Python 3 orchestration only | Compile five real Fortran mutants and reject each with native tests |

Verification alternatives: an imperative second boundary walker would duplicate the production structure and is rejected; closed-form arithmetic catches boundary, offset and orientation faults differently; separate-process metamorphic peeling catches inconsistent recursion of rings without calculating expected cells. Both Go checks share a parser and clockwise convention, so fixed Fortran tests and mutants reduce but do not eliminate common-mode risk. No independent holdout yet. Python is not the oracle.

## Reproduction

From repository root run: cd katas/KATA-000051 && bash tests/run.sh

Authentic local rerun on 2026-10-26: GNU Fortran 14.2, Go 1.23.2; RED compiles and fails with expected 'FAIL native'; GREEN 74,127 native assertions; Go race detector succeeds; 270 seeded sizes with two invalid input rejections; 5/5 compilable mutants killed. Exit code 0. The script regenerates evidence logs in its local workspace. Remote CI is separately required.

## Ninja, throughput and governance

Ninja v0.1.29 review: confirmed, not incorporated; no skill modification or causal performance claim. The metamorphic test was corrected after an initial version reused Oracle A for inner expected cells. Candidate ID/fingerprint remain unchanged; no publication or release milestone is credited. PR review, exact-head GitHub Actions, squash merge and post-merge checks are mandatory. Holdout evaluation at 90 published is unchanged.
