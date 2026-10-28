# KATA-000059 — Robot Name: randomized unique names under concurrency

**Status:** GREEN locally, `development_complete=true`; **not** remotely certified, reviewed, merged, or published. Source concept: [Exercism robot-name](https://github.com/exercism/problem-specifications/tree/main/exercises/robot-name), [MIT](https://github.com/exercism/problem-specifications/blob/main/LICENSE). The description is a conceptual reference, **not** copied here. All source/tests/oracles/fixtures were authored in this experiment. No upstream starter or canonical tests were imported.

## Domain and invariants

Each robot starts unnamed. Its first `name` query allocates `AA000`–`ZZ999` from a factory-wide namespace. A repeated query is idempotent; `reset` releases the reservation and the next name must differ from its immediately prior one; `retire` frees the name and ID. All simultaneously active robots must have unique names, even under concurrent allocation. The shared factory is `RobotFactory.shared`; isolated factories define independent namespaces for testing/tenants. Exhaustion is explicit, not an infinite collision loop. A single robot cannot obtain a different name in a capacity-one test namespace after reset.

Production randomness is supplied by Swift's system RNG. It does **not** follow a counter or predictable affine permutation. Seeded SplitMix64 exists **only** for reproducible testing and is not secure. At high occupancy, bounded rejection sampling falls back to randomized reservoir sampling of remaining names, ensuring termination while preserving a random choice. Worst-case allocation O(676,000), usual allocation expected O(1); reservations O(active robots), actor-serialized operations.

## Language decisions — before workflow lookup

- **Swift 6.2 (chosen):** `actor` gives compile-time isolation of mutable name reservations and makes concurrent uniqueness observable in tests. `SystemRandomNumberGenerator` is the platform default. Swift's explicit async calls are the central learning goal.
- **Go (alternative):** mutex + crypto/rand would be appropriate and explicit but repeats an existing concurrency experiment and adds manual synchronization.
- **Erlang (alternative):** a GenServer mailbox serializes reservations naturally, but process lifecycle supervision and naming semantics add unrelated infrastructure.
- **Ada (alternative):** protected objects could enforce strong bounded invariants, but GNAT was not available locally and no GREEN could honestly be declared. No language was chosen solely for existing CI.

| Role | Strategy, language, evidence |
|---|---|
| Implementation | Swift 6.2 actor; active set + lazy random reservations, bounded rejection + reservoir fallback; `src/RobotFactory.swift` |
| RED/GREEN | Native Swift 6 actor tests, 1200 seeded robots, 250 real system RNG, 200 resets, 600 concurrent tasks, 8-slot exhaustion; `tests/NativeTests.swift` |
| Independent oracle A | Ruby `Set` state machine validates traces, live reservations, idempotence, reset and retire; does not reproduce Swift's RNG or actor logic |
| Independent oracle B | Ruby Cartesian product of tiny name universes + pigeonhole/exhaustion: full finite universe equals the observed set regardless of random order |
| Alternative | Deterministic PRNG reference rejected as a primary oracle: reproducing the random stream would be brittle and share algorithmic assumptions; explicit model and combinatorial bound detect distinct faults |
| Metamorphic | Insert redundant `name` without affecting later seeded sequence; repeat same seed and compare; reject invalid configuration |
| Shared error risk | Both languages assume `AA000` shape and capacity semantics; Ruby oracle is sequential and cannot establish race freedom, so Swift task-group stress separately checks concurrency. RNG quality is not proven by uniqueness or seeded diversity. |
| Toolchain/commands | Swift 6.2.1, Ruby 3.3.8; `bash tests/run.sh` runs compiled behavioral RED, native GREEN, ThreadSanitizer-instrumented native GREEN, Ruby oracle, and two compiled mutants. CI: `.github/workflows/swift-robot-name-kata.yml` (Swift setup 6.2, Ruby setup 3.3). Genkidama `eng/ci/registry.json` maps Swift to the `swift` family and Ruby to `scripting`; the kata workflow runs both actual toolchains, not a substitute language. |

## Test results and limitations

Local `bash tests/run.sh`: RED compiled and failed for duplicate names; GREEN compiled and executed with Swift 6.2.1; Ruby 3.3.8 independently verified 100 histories / 11,365 operations and 10 exhausted finite universes; both mutants were compiled and behaviorally killed. See `evidence/local-run.txt`. Test-seeded SplitMix64 is not a production RNG; the CLI accepts seeds to make differential runs reproducible. ThreadSanitizer instruments the native 600-task concurrency suite; a passing dynamic race detector is not a proof of absence of all scheduling bugs. Exhaustion semantics and `retire` extend the minimal upstream concept as explicitly documented, without implying upstream requirements.

## Licensing and provenance

Concept description blob `fca3a41aeccc9ce1e2839ec947ffcf8e6ef8e2bb` and upstream MIT license blob `6813d6298df9a46da6485050e8a5fcd61ab79879` were inspected independently. The MIT notice is attributed here; no third-party code, canonical fixtures or starter files were copied. Source, native tests, oracle, synthetic data and CI are original, covered by this repository's MIT license. No source scan performed in this unit: KATA-000059 was already discovered in `exercism-20261017-part1` and retains its fingerprint.
