# KATA-000040 — Custom Set: Swift 6.2 and independent Go map/bitset oracles

**State:** GREEN locally, development complete; **NOT verified/published**. Existing
candidate `KATA-000040` / `exercism-spec-custom-set`, never a new ID. Authored
2026-10-27 against `dev` SHA `0d97c338cb8702265ad6fda4381cbd9336197f61`
(catalog blob `9e303fc1eb0fe964d84e10fb85b19e43148ca4ee`). Reconcile any
other agent's commits before a PR; do not copy the old catalog wholesale.

## Contract and invariants

A custom set stores distinct signed 64-bit integers, independent of input order
and duplicates. Its observable canonical order is ascending. Supports contains,
insert, remove, union, intersection, difference, equality, subset and disjointness.
Copying a set then mutating it must not mutate the original. Handles empty inputs,
repeated elements, negatives and `Int64.min/max`. Driver accepts newline-delimited
JSON objects with `a`, `b`, `insert`, `remove`; emits the ten observable properties
and results in JSON. Invalid JSON/type/required fields must be rejected with
nonzero exit status. No reliance on hash order. Construction O(n log n), contains
O(log n), insert/remove O(n), union/intersection/difference O(n+m).

## Rights audit per artifact

The **concept only** is from Exercism's MIT-licensed problem specifications:
`exercises/custom-set/description.md`, blob
`33b90e28d7f87328d24652822d4424354b2590a1`, at
https://github.com/exercism/problem-specifications/blob/main/exercises/custom-set/description.md.
The MIT LICENSE is blob `6813d6298df9a46da6485050e8a5fcd61ab79879`:
https://github.com/exercism/problem-specifications/blob/main/LICENSE.
No upstream starter, canonical fixtures, tests, data or code were copied. The
Swift source, Swift native tests, Go models, shell runner and Python mutation
orchestration were independently authored for Katas under its MIT license.

## Language selection BEFORE examining workflow

Compared **Swift**, **Haskell**, **Ada** and **C++20** for set algebra and
value semantics. Swift won for Array copy-on-write, explicit value types,
mutation isolation and simple persistent-style algebraic operations. Haskell
would make immutable sets and equational laws elegant, but hide copy-on-write
and explicit mutation. Ada would teach bounded containers and contracts but
requires extra ceremony for a generic signed-int set. C++20 offers RAII and
ownership, but exposes manual copy/move decisions rather than Swift's value
semantics. A habitual Go implementation using a map would be concise, but
would lose the sorted representation / COW lesson and duplicate the reference.
This selection was made on domain affinity, not CI convenience or language quotas.
After selecting, consulted Genkidama `ChicoDotNet/Genkidama` `dev`
`eng/ci/registry.json` blob `24bde39c748dd3903789fd20eace80894a4735fb`
and adapted the established Swift 6.2 / Go 1.23 toolchain pattern to a dedicated
Ubuntu 24.04 workflow.

## Three independent choices, not just language diversity

| Role | Language | Technique |
|---|---|---|
| Implementation | Swift 6.2 | Sorted unique array; binary lower bound; linear two-pointer merge for set algebra; Array copy-on-write for mutation isolation. No built-in `Set` in implementation. |
| Native RED/GREEN | Swift 6.2 | Compilable behaviorally failing stub, 28,817 native assertions including 2,400 generated algebraic cases, copy isolation, extreme signed values and partition identities. |
| Independent oracle A | Go 1.23.2 | Hash-map membership and mathematical set operations, canonicalized only for comparison. No two-pointer merge. |
| Independent oracle B | Go 1.23.2 | Bounded 41-bit integer bitset (`-20..20`), algebra by OR/AND/AND-NOT; 3,000 model-vs-model crosschecks and selected direct Swift crosschecks. |
| Metamorphic | Go driving Swift process | 704 swapped-input pairs genuinely executed through the Swift JSONL driver; compare commutativity of union/intersection. |
| Mutation | Python orchestration, Swift compilation | Two syntax-valid source mutants (binary-search direction and union branch) killed by native behavioral assertions. Python computes no expected set values. |

**Alternatives:** a second sorted-array implementation or a translation of the
Swift two-pointer merge would share control-flow defects. Hash-map membership
catches ordering/duplicate/merge mistakes; bounded bitsets catch errors in the
map reference independently through algebraic identities. Metamorphic swapped
requests expose input-order dependence even when both models share a mistaken
contract. Shared risks remain: both references and Swift agree on signed
integer semantics, union/subset direction and canonical ascending output; the
random generator is deterministic and cannot replace independent holdouts.

## Real execution, reproducibility and limits

```sh
cd katas/KATA-000040
bash tests/run.sh
```

Executed locally with Swift 6.2.1 and Go 1.23.2 (Linux x86_64), exit 0:
RED compiled and failed **behaviorally**; native GREEN **28,817 assertions**;
Go `go test -race -count=1 -v ./...` PASS; `go vet ./...` PASS; **1,408**
genuine Swift JSONL requests, **704** swapped pairs, **3,000** independent
Go map-vs-bitset comparisons; malformed request rejected; **2/2** compiled
Swift mutants killed. Logs are in `evidence/{red,green,oracle,mutations}.txt`.
A failed earlier differential run exposed Go `nil` slices serialized as `null`
instead of `[]`; corrected the Go generator, reran. A second failure exposed
an ambiguous mutation anchor, corrected and reran. Neither is hidden.

CI workflow `.github/workflows/swift-custom-set-kata.yml` is **prepared but
has NOT run**. No exact-head CI, review, or remote branch exists at checkpoint.
Do not mark verified or published on local evidence alone.

## Ninja and governance

Ninja v0.1.29 conclusion **confirmed**, no skill edit, no causal claim.
See `evidence/skill_review.md` and
`docs/audits/ninja-custom-set-swift-go-2026-10-27.md`.
Provisional difficulty 3/5 and ranking 74/100, **not independently calibrated**.
Before publishing: reconcile `dev`, audit licenses, exact source hashes, run
all relevant CI gates on PR HEAD, secure independent review, squash to `dev`,
verify post-merge SHA/catalog and CI, then record publication provenance.
No holdout or 0.16% scale-up before 90 published.
