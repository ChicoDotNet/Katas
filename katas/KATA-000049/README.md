# KATA-000049 — Flower Field (Fortran 2008 + Go prefix-sum oracle)

**State:** GREEN locally, development complete; **not verified, not published**. A feature PR and exact-head CI are required. Candidate ID `KATA-000049` and fingerprint `exercism-spec-flower-field` are preserved from the dev catalog.

## Domain and invariants

A rectangular board uses `*` for flowers and `.` for empty cells. Flowers remain unchanged. Empty cells become `1`–`8` according to the eight adjacent cells, or remain `.` if no adjacent flower exists. No wraparound. Include 0×0, 1×N, N×1, dense, empty, irregular, invalid and extreme shapes. The CLI accepts 0..512 dimensions and rejects malformed sizes, truncated rows, wrong widths and invalid symbols. `.` is an original unambiguous transport convention rather than the conceptual source's spaces. O(rows×cols) time and space.

## Rights audit by artifact

Concept reference only: Exercism problem-specifications `exercises/flower-field/instructions.md`, MIT-licensed blob `bbdae0c2cb1fa4a25852a885a02a4f42b9b677e7`; repository MIT LICENSE blob `6813d6298df9a46da6485050e8a5fcd61ab79879`. No starter implementation, canonical fixtures, upstream tests or images imported. All Fortran, Go, Python and shell source and test inputs are newly authored for this repository under its MIT license.

## Language selection BEFORE CI

Compared **Fortran** (rank 1: column-major rank-2 arrays, explicit zero-padded halo and contiguous 3×3 intrinsic sums), **Julia** (rank 2: natural matrix broadcasting but hides allocation and boundary choices), **R** (rank 3: matrix vectorization but more indexing and conversion complexity), and **Ada** (rank 4: strong bounded index contracts but extra ceremony for this numerical stencil). Fortran wins on distinctive stencil/halo learning, not workflow convenience. Genkidama `dev/eng/ci/registry.json` native family was consulted *after* language selection; CI uses genuine gfortran and Go.

## Independent implementation, tests, oracle

| Role | Language | Technique |
| --- | --- | --- |
| Implementation | Fortran 2008, gfortran 14.2 local | Allocate 2D halo, `sum` a 3×3 slice per empty cell. |
| RED/GREEN | Fortran, `-std=f2008 -fcheck=all` | Compilable wrong identity stub fails hand-calculated 3×3 board. GREEN: 2,054 assertions, 512 exhaustive 3×3 boards, transpose and reflection. |
| Oracle | Go 1.23.2, `go test -race` | Independent **2D integral image / summed-area table** and four-corner inclusion–exclusion, 240 deterministic random boards and four large/degenerate cases. |
| Metamorphic | Go invoking real Fortran CLI | Rotate/reflect input, execute Fortran again, compare transformed outputs. |
| Mutation | Python 3 orchestrating genuine Fortran | Compile three distinct wrong Fortran variants; native tests kill 3/3. Python never calculates expected boards. |

**Two strategies evaluated:** A second eight-neighbor traversal was rejected because it duplicates the stencil's logic. A 2D prefix sum was chosen to detect independent indexing and inclusion–exclusion errors. Rotation/reflection additionally catches coordinate/orientation errors without depending on reference outputs. Shared assumptions remain: the eight-neighbor definition, rectangular dimensions, ASCII `*`/`.`, and CLI framing. The independent holdout at 90 published is still required.

## Reproduction and results

Run from repository root:

    cd katas/KATA-000049
    bash tests/run.sh

The script compiles behavioral RED, native GREEN, real Fortran CLI, Go differential/metamorphic oracle with race detector, and three compiled mutants. Separate `go vet ./...` was run locally. Local 2026-10-27: gfortran 14.2.0, Go 1.23.2; 2,054 native assertions; 240 seeded random differential boards, 4 large/degenerate boards, 6 invalid inputs rejected; 3/3 mutants killed; suite exit 0. Repeated after recovery in this run. The `evidence/ci.txt` placeholder is NOT remote certification.

## Ninja, retrabajo and governance

Ninja v0.1.29 review: **confirmed**, not incorporated; no skill edit or causal attribution. Local defects corrected: a 4×5 expected fixture incorrectly retained a 3×3 allocation (caught by bounds checks), and the CLI initially wrote each character separately (replaced by whole-row writes). A 720-case stress variant showed intermittent process timeouts; the reproducible committed suite uses 240 seeded cases, 512 exhaustive native boards, four large/degenerate cases and direct Go output capture. Do not cite exploratory stress as certification.

Known limits: 512×512 dimensions, ASCII transport, one request per CLI process. Publication requires exact-head CI of native compiler, RED/GREEN, Go oracle and mutants, catalog and governance; substantive independent review, squash merge to dev, and post-merge reconciliation. No direct push to dev/main.
