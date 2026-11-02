# KATA-000010 — BugsZero: invalid game states by construction (Ada 2022)

**State: GREEN / development_complete after authentic GNAT 13.3 + Go 1.23.12 CI on initial source HEAD `ee3f5d932bfae3adfc0c3dce207ba094ae015245`.** Exact-head CI for this metadata commit remains required; independent review and publication are pending.

## Source and rights

Concept: https://kata-log.rocks/bugs-zero-kata. Kata-Log declares its own content public domain; linked legacy Trivia code, examples and starters have **not** been copied. Original Ada/Go code here is MIT under the repository license. The earlier published KATA-000001 already studies legacy Trivia characterization; this **different original game contract** studies constructing only valid game states and protecting invariants, not characterizing/refactoring Trivia. All detailed rules below are **local design decisions**, not claims about the upstream exercise.

## Domain, invariants and new local policy

A circular-board question game requires 2–6 unique player IDs (1..99), 1–4 categories, a board of 1–128 cells whose category IDs exist, and a nonempty question deck of 1–5 questions per category. No caller can default-construct the indefinite private `Game` type; `Create` validates every dynamic invariant and rejects invalid configuration. `Play` accepts rolls 1–6 and alternates players. Positions wrap modulo board length; questions cycle per category. Correct answers gain a point unless a player is penalized, in which case a correct answer removes the penalty without scoring; wrong answers apply a penalty. These gameplay choices are original policy for this experiment.

CLI token stream: `P C B T`, followed by P player IDs, B board category IDs, C deck lengths, then T `(roll, correct[0|1])` pairs. Each output row is `player-index category question-index score penalized[0|1]`. Invalid input exits nonzero with `ERR` on stderr. No unlicensed fixtures or starter assets.

## Three independent language decisions

| Layer | Language / technique | Why |
|---|---|---|
| Production | **Ada 2022**, private indefinite type + validated constructor + bounded arrays | The teaching goal is to prevent representation of invalid games, not merely patch a mutable Trivia class. |
| Native RED/GREEN | **Ada 2022**, compiled behavioral assertions | Exercises constructor rejection, question cycling, score, penalty and wrap with authentic GNAT. RED replaces one scoring statement with a valid but wrong behavior. |
| Oracle | **Go 1.23**, immutable event-history reconstruction | Recalculates each player's position and score from complete prefixes, and question indexes from prior visits; no mutable Ada-style counters are mirrored. 300 deterministic random histories, renaming/category permutations, invalid inputs. |

**Language comparison before inspecting CI:** Ada's private types, discriminants and range checks are directly relevant; Swift's immutable structs/failable constructors are strong but expose less of Ada's range contract discipline; Haskell's smart constructors/ADTs would also exclude invalid states but GHC is absent; Prolog offers relational invariants but is less direct for the imperative API. Reverting to Java/Go for convenience would weaken this distinct anti-invalid-state lesson. Ada requires a GNAT runner; lack of local GNAT is a certification blocker, not grounds to change language.

**Verification strategy comparison:** (1) stateful step-for-step translation in Go risks reproducing Ada transition mistakes; (2) chosen full-history reconstruction uses separate queries over past turns, and complements native assertions with deterministic randomized and metamorphic tests. Shared risks remain: both must agree on zero-based positions, one-based question indices, penalty-release policy, and exact CLI semantics. Permuting categories and player IDs probes some of those risks. Exhaustive model checking of all 128-turn histories is infeasible; the test suite is bounded and cannot prove absence of every invalid state.

## Reproduce (GNAT + Go required)

```bash
bash katas/KATA-000010/tests/run.sh
```

The GitHub-hosted run 41514728561 executed the script successfully. The script compiles a behaviorally wrong RED package, builds/runs native GREEN tests and Ada CLI, executes an independent Go oracle, and compiles/rejects three mutation variants. Workflow `.github/workflows/ada-bugszero-kata.yml` installs Ubuntu GNAT following the repository's existing Ada/Rust cross-language workflow and Genkidama's GNU/longtail adapter patterns. Initial source HEAD was verified via job 125515236221; metadata HEAD must also pass exact-head CI before review/merge.

## Ninja review

Ninja v0.1.29: **no_change** after observing authentic GNAT RED/GREEN, Go differential and compiled mutants. No holdout change and no causal attribution. Record runtime, defects, reruns and CI evidence only after they occur.

## Authentic remote execution (2026-11-02)

Initial source SHA `ee3f5d932bfae3adfc0c3dce207ba094ae015245`; [GitHub Actions run 41514728561](https://github.com/ChicoDotNet/Katas/actions/runs/41514728561), job `125515236221`, success. GNATMAKE 13.3.0; Go 1.23.12. RED compiled and failed behaviorally, GREEN 12 Ada assertions, 301 baseline scenarios / 2333 turns, 535 metamorphic sessions, 8 invalid inputs, three compiled Ada mutants rejected by Go. This is not local GNAT execution; the remote hosted runner supplied the compiler. New metadata HEAD requires fresh CI.
