# KATA-000027 — Tennis (clean-room finite-state scoring)

Status: green locally; development_complete=true proposed in this branch, NOT published. 2026-10-30. Ruby 3.3.8 and Go 1.23.2 tested locally; remote CI and independent review are required.

## Domain and invariants

Model one tennis game, not sets or tie-breaks. Players A and B score Love, Fifteen, Thirty, Forty, Deuce, Advantage, Win. Equal scores from 3-3 onward are Deuce; a two-point lead after four points wins. Points after a win are rejected, including an invalid player symbol; terminal error takes precedence. Every accepted point returns a new frozen snapshot. The CLI reads one history per line, with '-' representing an empty game, and prints a score or ERR:invalid / ERR:finished.

## Three independent language choices

| Role | Language | Why |
| --- | --- | --- |
| Implementation | Ruby 3.3 | Named finite states, immutable OO value snapshots, compact domain representation |
| Native RED/GREEN | Ruby + Minitest | Intentional parseable failing stub, 33 assertions against production class |
| Independent oracle | Go 1.23.2 | Mathematical cumulative point counts and first terminal prefix, not Ruby's state transitions |
| Metamorphic | Go driving real Ruby | Swap player A/B in observed histories and compare real CLI outputs |
| Mutation | Ruby + Go | Three syntax-valid Ruby variants tested by the independent Go oracle |

Before consulting CI, compared Ruby against Haskell (excellent ADTs, GHC unavailable locally), Kotlin (sealed states but more ceremony for this small automaton), and C++20 (closed enums but ownership details distract). Defaulting to Go/Java/Python for the implementation would primarily teach counters and switches rather than immutable Ruby snapshots. After choosing, consulted Genkidama scripting-family Ruby setup and adapted an isolated GitHub workflow. CI availability did not determine language selection.

Oracle strategy comparison: (1) translating the finite-state machine to Go risks correlated transition bugs; (2) independent prefix-count arithmetic chosen; (3) player-swap metamorphism adds a distinct symmetry check but cannot replace the reference. Exhaustively enumerates all 32,767 A/B histories of length 0..14, 1,000 seeded longer histories, five invalid cases and 1,000 transformed executions: 34,772 actual Ruby CLI histories, 33,139 observed metamorphic pairs. These are test executions, not distinct legal games. Three syntax-valid mutants were rejected. The reference and implementation share tennis semantics and error precedence; bounded histories do not constitute a proof. No original third-party starter refactor, sets, tie-breaks or independent holdout are claimed.

## Rights per resource

Kata-Log Tennis conceptual page: https://kata-log.rocks/tennis-kata — site's own text declared public domain; third-party starter implementations linked there were NOT imported, audited, copied or used as fixtures. All files under this kata, its workflow, tests, and reference model are original MIT under repository license. The scope is a clean-room scoring exercise, not completion of Kata-Log's four starter refactorings.

## Commands actually run locally

    cd katas/KATA-000027
    bash run.sh
    ruby -c src/tennis_red.rb
    TENNIS_IMPL=tennis_red ruby -I src tests/test_tennis.rb --seed 27030  # expected RED failure
    ruby -I src tests/test_tennis.rb --seed 27030
    go vet tests/oracle.go
    go run tests/oracle.go src/cli.rb
    ruby tests/mutations.rb

RED: parsed and failed behaviorally. GREEN: 33 native assertions. Go: 34,772 histories. Mutation: 3/3 killed. Actual CLI was executed. Ninja v0.1.29 review: no_change. Independent reference detected a real AAAAZ error-precedence defect, fixed and regressed. No causal Ninja claim, no holdout modification. See evidence/skill_review.md.

Do not mark verified or published until all required CI checks pass on exact PR head, independent review is recorded, and a governed squash merge to dev with catalog provenance is reconciled.
