# Ninja — KATA-000051 engineering and transfer audit (2026-10-26)

- Baseline: dev 0d97c338cb8702265ad6fda4381cbd9336197f61; live catalog 26 published, 4 green, 31 discovered (61) at branch creation. No README counters used.
- Existing discovered candidate KATA-000051, source fingerprint exercism-spec-spiral-matrix; source and license blobs checked directly: MIT instructions 01e8a77f808ebf669389df96d5a86ae06cc23f69, MIT license 6813d6298df9a46da6485050e8a5fcd61ab79879. Concept only; no upstream starter/tests copied.
- Problem-first language choice: Fortran over Julia/Rust/Go for allocatable column-major matrix and explicit boundary indexing. Native Fortran tests. Go for independent closed-form ring arithmetic and separate-process metamorphic peeling; Python only mutation orchestration.
- Local compiler evidence: genuine GNU Fortran 14.2, Go 1.23.2, 74,127 assertions, 270 differential/metamorphic sizes, 2 invalid-size rejections, 5/5 compiled mutants killed, race detector passed, runner exit 0.
- Retrabajo: initial metamorphic check used a formula-computed inner ring; corrected to compare distinct production runs at n and n-2.
- Ninja v0.1.29 conclusion confirmed; no edit, no independent holdout and no causal skill-effect claim.
- The reviewable branch is kata/000051-spiral-fortran-go-20261026. CI exact-head, independent review and squash merge are pending; this document must not be read as publication evidence.
