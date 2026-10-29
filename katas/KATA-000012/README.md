# KATA-000012 — Christmas Lights: Boolean and saturating-brightness grids

Source: [Kata-Log Christmas Lights](https://kata-log.rocks/christmas-lights-kata). The site's **own text** is explicitly public domain; this folder contains **new original MIT code, tests, generated inputs and documentation**, not the linked starter repositories, Advent of Code materials or images. No third-party fixture was imported.

## Domain and invariants

The two independent views of an initially dark `n×n` board (`1 ≤ n ≤ 1000`) are updated by inclusive axis-aligned rectangles. Operations: `1` turn on (Boolean `true`, brightness `+1`), `2` turn off (`false`, brightness `max(0,b−1)`), `3` toggle (`not`, brightness `+2`). Both views are updated by the same command, in order. An invalid operation or rectangle is rejected **before** either view is mutated. At most 10,000 operations per CLI invocation; brightness cannot overflow 64-bit signed integers under this bound. Coordinates are zero-based externally, one-based inside Fortran.

Input format: `n m` followed by `m` lines `op x1 y1 x2 y2`; output: `lit_cells total_brightness`. The variable `n` is a testing generalization of the source's 1000×1000 board, not a change to its 1000×1000 example. The CLI rejects malformed inputs with nonzero exit status; it does not expose partially updated state. No parallelism, GPU or performance superiority is claimed.

## Implementation-language decision **before** CI

- **Fortran 2008 (chosen):** multidimensional arrays and explicit integer kinds make inclusive indexing, array traversal and saturating updates visible. Native column-major layout is interesting for a million-cell grid; the core is original and allocates O(n²) cells, running O(total affected rectangle area).
- **Julia:** equally strong or stronger for high-level array operations and visualization, but here the central learning is precise bounded Fortran indexing and memory representation, not notebook ergonomics.
- **Ada:** excellent constrained ranges and contracts, particularly for rejection, but the dominant work is a dense matrix transformation; the explicit Fortran implementation exposes the off-by-one risk more directly.
- **C++20:** suitable for contiguous storage and performance, but would shift attention to ownership and generic containers. A preexisting C++ CI is irrelevant to the language decision.

The family reference is `ChicoDotNet/Genkidama`, `eng/ci/registry.json` (`native` family) and `eng/ci/run-family`; these describe toolchain/gate patterns, not proof of this kata. The actual workflow is `.github/workflows/christmas-lights-kata.yml` and must run on the **PR exact head** before certification.

## Three separate choices

| Responsibility | Language and technique | Evidence |
|---|---|---|
| Implementation | Fortran 2008; dense Boolean + 64-bit brightness matrices | `src/lights.f90`, `src/lights_cli.f90` |
| RED/GREEN | Fortran 2008 native assertions; a compilable deliberately incorrect RED stub | `tests/lights_red_stub.f90`, `tests/test_lights.f90` |
| Independent oracle | Go 1.23.2; **coordinate compression**, partition into disjoint weighted rectangles, evaluate each representative | `tests/oracle.go` |
| Additional verification | Go exhaustive 1×1 command histories, seeded random rectangles, split-rectangle and disjoint-commutativity metamorphisms | `tests/oracle.go` |
| Mutation | Python 3 generates three source mutations; Fortran compiles them, Go oracle must reject each | `tests/mutations.py`, `tests/run_all.sh` |

**Competing verification strategies:** (a) a second naive per-cell update would reproduce Fortran's index loops and risk the same inclusive-boundary defect; (b) **coordinate compression with area weights**, chosen, represents only operation boundaries and is structurally independent of dense grid traversal. Metamorphic splitting and commuting disjoint rectangles add relational evidence, not merely another translation. Remaining shared risk: both models interpret the same operation semantics and coordinate conventions; malformed input behavior is native-tested but not exhaustively differentially tested. The 1×1 exhaustive corpus detects saturation and toggle errors; generated larger rectangles detect boundary errors. This is not a formal proof.

## Reproduce

```bash
cd katas/KATA-000012
# gfortran 14.2.0, go1.23.2, Python 3.13.5, Bash
bash tests/run_all.sh
```

The runner compiles RED and **requires behavioral failure**, compiles GREEN, runs 2,074 independent oracle comparisons (1,093 exhaustive one-cell sequences; 500 seeded random; 1 large-board; 360 split-metamorphic checks; 120 disjoint-operation checks), and compiles/rejects three distinct mutants: incorrect toggle, negative brightness and exclusive end-coordinate. `go vet` is also run. The precise local output and limitations are in `evidence/local-2026-10-29.md`. A local pass is **not** remote CI, review or publication.

## Provisional difficulty and skill review

Original catalog triage rates this Starter exercise `3/5`. It is not relabeled as a hardest-first global winner. Its two simultaneous grids, inclusive rectangles and saturation make it useful for cross-representation oracle validation. Provisional single-reviewer rubric: transfer 17/20, depth 16/20, oracle 15/15, TDD 13/15, novelty 7/10, pedagogy 9/10, portability 5/5, maintenance 4/5 = **86/100**, not independently calibrated. This score is distinct from the source difficulty.

Ninja v0.1.29: **confirmed locally** OBS-001's array transformation principle with a stronger, structurally different oracle; **no skill change** or causal claim. No independent holdout or active-time productivity comparison has been performed. Publication requires reviewed PR, exact-head required CI, squash merge into `dev` and post-merge reconciliation.

## 2026-10-29 input-framing hardening (independent follow-up)
An adversarial holdout revealed that list-directed Fortran `read(*,*)` accepted an undeclared command after `m` lines and silently ignored extra fields. The executable previously returned success for `3 0\\n1 0 0 2 2\\n` (reported `0 0`), violating the README's malformed-input rejection contract. The CLI now parses individual records, rejects extra fields and nonblank trailing records, and allows blank trailing lines. `tests/cli_contract.sh` is a required gate: one valid case and eight behavioral rejection cases. This is a **real bug fix**, not an additional published kata. The record buffer is limited to 1,024 characters; overlong-record behavior is not exhaustively audited. The original Fortran 22 assertions, Go 2,074 comparisons, three compiled mutants and Go Vet remain required. No claim of formal verification.
