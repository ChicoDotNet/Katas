# KATA-000046 — geometric metamorphic hardening (2026-10-28)

**Scope:** additive tests, no production-code change, no new published kata, no migration.
The previously published Swift 6 implementation, native RED/GREEN and Python differential enumeration remain the baseline. This extension adds a Go 1.23 *constructive* oracle and symmetry invariants. Source and fixtures authored here; no Exercism starters, canonical test data or third-party code imported.

## Domain and techniques

- Eight-direction nonwrapping rectangular word search, zero-based row/column coordinates.
- Existing reference: Python enumerates all starting cells and eight directions, returning the first according to the local deterministic tie-break.
- New independent technique: Go **constructs** boards with a unique sequence of distinct `B..K` characters on a path against an `A` background. The correct endpoints are known **before** invoking Swift. Eight dihedral symmetries transform the board and expected coordinates. Reversing the word swaps endpoints. An impossible `ZZZ` must remain absent.
- Multi-occurrence random boards test *existence* invariance under symmetry and independently validate any returned witness path. They intentionally do **not** assert transformed coordinates equal the transformed tie-break winner: reflection/rotation can change which occurrence wins.
- Transform self-checks: 90° + 270° = identity, reflection twice = identity, transpose twice = identity, 90° four times = identity.
- Risk of correlated errors: both systems agree on row/column convention and eight-direction geometry. Constructive unique witnesses and symmetry identities reduce reliance on a second search implementation, but do not prove all possible tie-break outcomes. The existing Python enumeration remains necessary.

## Three separate language decisions

| Layer | Selected | Why / alternative |
|---|---|---|
| Implementation | Swift 6 (unchanged) | Value-typed optional coordinates and explicit match result; Kotlin or Go would be reasonable but changing language offers no proven benefit here. |
| RED/GREEN | Swift 6 (unchanged) | Native compilation and behavioral failure via `KATA_RED`; verifies input and directional contracts. |
| Existing oracle | Python 3 (unchanged) | Exhaustive coordinate enumeration, 400 seeded boards; detects tie-break errors but structurally resembles Swift loops. |
| Added oracle | Go 1.23 | ASCII byte-grid dihedral transforms, constructive witnesses and separate executable. Haskell would express pure transforms elegantly but adds a runtime for no clear detection gain; Ruby would be concise but offers no specific advantage over Go's explicit index bounds. |

**Strategy comparison:** coordinate enumeration versus constructive known-answer generation plus metamorphic symmetry. The latter detects omitted directions and incorrect endpoint arithmetic without translating the Swift search loop. Go was selected for test-model clarity, **not** because CI already existed.

## Reproducibility

From `katas/KATA-000046`: `bash tests/geometry-run.sh`. This compiles and runs native Swift GREEN; compiles and runs a Swift behavioral RED and checks its failure signature; builds/vets the Go oracle and executes it against the actual Swift CLI; compiles two independent Swift mutants and requires the oracle to reject both.

Local environment: Swift 6.2.1, Go 1.23.2, Python 3.13.5. Exact local run: 1,760 transformed boards (180 planted groups + 40 random groups, eight symmetries each), 11,040 symmetry existence checks, 4,320 constructive witness/absence checks, 7,912 validated witnesses, two mutants detected. Full run PASS. The original Python differential suite is separately covered by the existing Swift workflow; this new script does not claim to have run that suite.

**Ninja review:** `confirmed` for OBS-018 (coordinate conventions, ties and independent oracles); no skill edit, no causal improvement claim. The original source is [Exercism word-search specification](https://github.com/exercism/problem-specifications/tree/main/exercises/word-search), MIT licensed in [LICENSE](https://github.com/exercism/problem-specifications/blob/main/LICENSE); verified upstream description blob `e2d08aa9ee69577bf769e135959240c632c5614b`, license blob `6813d6298df9a46da6485050e8a5fcd61ab79879`. No third-party code copied.

**Remote certification:** pending PR exact-head CI, independent review and merge; no change to `published` count.
