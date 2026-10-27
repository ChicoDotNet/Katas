# KATA-000040 Ninja / rights / language / oracle audit — 2026-10-27

- Existing ID and fingerprint: KATA-000040, exercism-spec-custom-set.
- Concept source: Exercism `custom-set/description.md` MIT blob
  `33b90e28d7f87328d24652822d4424354b2590a1`; LICENSE MIT blob
  `6813d6298df9a46da6485050e8a5fcd61ab79879`. No external code,
  starters, tests or fixtures copied.
- Domain invariants: uniqueness, membership, stable canonical order, algebraic
  identities, copy isolation, Int64 boundaries, malformed request rejection.
- Main language candidates considered before CI: Swift, Haskell, Ada, C++20.
  Swift selected for value semantics and COW; not to fill a quota.
- Tests Swift native RED/GREEN; oracles Go hash-map and 41-bit algebraic bitset,
  two independent techniques; metamorphic swapped-input real Swift process.
- Runtime: Swift 6.2.1, Go 1.23.2, 28,817 native assertions, 1,408 genuine
  differential requests, 3,000 map/bitset crosschecks, 2/2 mutants killed.
- Retrabajo: corrected Go nil-slice `null` JSON transport and nonunique
  mutation anchor. Both discovered by actual failed runs, then full rerun PASS.
- Ninja v0.1.29 skill SHA `32cb01f2e088453762f5c79239d1f11e6991bf83`.
  Conclusion `confirmed`, no skill change, no causal attribution.
- Status: GREEN LOCAL, development complete; CI unexecuted, no PR/review/merge.
- Provisional ranking 74/100: transfer 15, depth 13, oracle 16, TDD 12,
  novelty 5, pedagogy 7, portability 3, maintenance 3. Single-author rubric,
  no independent calibration. Difficulty 3/5 provisional.
- Main release gate remains 36 newly published; no published increment here.
