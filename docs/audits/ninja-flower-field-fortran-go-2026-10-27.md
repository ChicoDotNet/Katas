# KATA-000049 — Ninja audit, 2026-10-27

- Candidate: preexisting `KATA-000049`, fingerprint `exercism-spec-flower-field`; no new scan and no duplicate ID.
- Domain: 2D local stencil, no wrap, eight neighbors, empty/flower preservation; bounded rectangle. Four languages considered *before* CI: Fortran, Julia, R, Ada; Fortran chosen for column-major 2D array slicing and halo semantics.
- Rights: Exercism conceptual instructions MIT, blob `bbdae0c2cb1fa4a25852a885a02a4f42b9b677e7`; LICENSE MIT blob `6813d6298df9a46da6485050e8a5fcd61ab79879`. No upstream tests, starters or fixtures copied.
- RED: compilable Fortran identity stub fails hand-calculated nontrivial fixture; `evidence/red.txt`.
- GREEN: native gfortran 14.2, 2,054 assertions, exhaustive 512 three-by-three boards, transpose and reflection; `evidence/green.txt`.
- Independent Go 1.23.2 prefix-sum model (not translated stencil): 240 random boards + four large/degenerate; two real-process metamorphic transformations; six malformed-input rejections; Go `-race` succeeds; `evidence/oracle.txt`.
- Mutation: 3/3 compiled Fortran mutants killed by native behavior; Python is orchestration only; `evidence/mutations.txt`.
- Retrabajo: (1) native expected 4×5 matrix initially retained 3×3 allocation; gfortran bounds check revealed it. (2) Fortran CLI emitted each character through formatted I/O, causing Go subprocess test to exceed timeout; changed to one output line per row. A subsequent 720-case stress run exposed intermittent per-process timeouts and a 512×512 subprocess termination under the local runner. The committed repeatable suite uses 240 randomized boards, 1×512 / 512×1 boundaries, 128×128 and 256×256 large boards, plus exhaustive native 3×3 tests. Redirecting Go test output to an evidence file rather than piping it through `tee` removed an observed local runner hang. The full committed suite was rerun twice and passed. The earlier 720-case stress success is exploratory only, not the committed CI contract. No false GREEN asserted during failures.
- Genkidama: `ChicoDotNet/Genkidama` dev `eng/ci/registry.json` native family; Katas workflow installs/uses genuine gfortran and Go, not an interpreter substitute.
- Ninja skill: v0.1.29 `confirmed`, no edit. No causal attribution; independent holdout remains mandatory at 90 published.
- Publication gate: **GREEN local only**, not remotely certified; feature PR, exact-head CI, substantive review, squash merge and post-merge catalog reconciliation are pending. Do not claim verified/published.
