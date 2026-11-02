# KATA-000029 — Tic Tac Toe: reachable board states

**Status:** GREEN locally on 2026-11-02, **NOT remotely certified, NOT published**. This is an original, bounded adjudication exercise inspired by the public-domain rules on [Kata-Log](https://kata-log.rocks/tic-tac-toe-kata), **not** a copy of any linked starter, fixture or upstream implementation. Original code is MIT under the repository license. The rules are in the source page's own public-domain content; upstream starter rights have not been assumed.

## Domain, invariants and contract

For a 3×3 board, X moves first, marks alternate, moves occupy empty cells, and the game stops immediately on the first winning row, column or diagonal, or on a full board. The CLI consumes one row-major nine-character board per UTF-8 input line (`X`, `O`, `.`). It returns one line per board:

- `ERR:format` for length or character violations;
- `ERR:unreachable` for impossible positions (turn counts, incompatible winners, wrong last mover);
- `WIN:X`, `WIN:O`, or `DRAW` for terminal positions;
- `NEXT:X|MOVES:0,1,...` (or O) for ongoing positions, listing legal zero-based cells in ascending order.

This deliberately verifies board *reachability*, not only winner detection. It does not implement an AI opponent, a multiplayer server or the upstream starter API. It does not accept arbitrary board sizes. Java uses immutable input strings and does not retain mutable game state between requests.

## Language choice **before** CI

| Candidate | Distinctive fit | Cost |
|---|---|---|
| **Java 21 (chosen)** | Explicit pure contract with predictable fixed-grid validation and standard-library-only compile; easy to contrast static reachability conditions with history enumeration. | No compile-time proof of reachable states; requires an external oracle. |
| Haskell | Algebraic game states and pure transitions can make impossible transitions hard to represent. | GHC unavailable in this runner; cannot honestly declare GREEN here. |
| Prolog | Declarative constraints and relations can model reachability elegantly. | SWI-Prolog unavailable locally; constraint encoding needs its own exhaustive independent check. |
| Swift | Value-semantic boards and enums fit turn/terminal modeling. | Adds no clearer structural contrast than Java for this specific static predicate. |

**Contrafactual:** reusing Go for implementation would make it easy to accidentally share the oracle's representation. Java's static count-and-winner proof contrasted with Go's exhaustive game-history traversal is the central experiment, not a quota for Java. Toolchain and CI were selected only after this comparison; workflow adapts Genkidama's JVM/Java setup family (`eng/ci/registry.json`, `polyglot.yml`) and Katas' Java workflow conventions.

## Three independent language decisions

| Role | Language / method | Evidence |
|---|---|---|
| Production | Java 21, static parity/winning-line constraints, no search | `src/TicTacToe.java`, `src/Main.java` |
| RED/GREEN | Java 21 native assertions and a compilable, behaviorally wrong stub | `tests/Stub.java`, `tests/NativeTests.java` |
| Oracle | Go 1.23.2, BFS/graph enumeration of all legal histories from the empty board, stop on terminal | `tests/oracle.go` |
| Mutation harness | Python 3.13 (or runner Python), **not an oracle** | `tests/mutations.py` |

**Compared verification strategies:** (A) directly reimplement Java's count/winner constraints in Go (rejected: duplicate logic) vs (B) enumerate all legal game histories via BFS, storing only reachable states (chosen). The Go model produces 5,478 reachable positions, checks all 19,683 possible ternary boards and 4,040 additional dihedral transforms. The oracle uses row/column/diagonal geometry too: shared game rules are unavoidable, but traversal vs a closed-form predicate makes off-by-one turns, illegal post-win moves and inconsistent winner counts independently detectable. Eight extra malformed/adversarial lines exercise protocol handling.

**Metamorphic property:** rotating/reflection-transforming a board preserves reachability; Java's transformed results must match the independently enumerated Go model. For ongoing boards, Go computes expected legal moves directly from the transformed board; it does not copy Java's move list.

**Risk of common-mode mistakes:** both implementations necessarily agree on the game's 3×3 winning geometry, starting mark and move ordering. A misread specification could fool both. The native tests anchor representative wins, draws, illegal turns and terminal precedence; the Go model also checks the entire finite state space. The exhaustive bound is specific to 3×3 and does not scale to larger boards without another technique.

## Reproducible execution

```bash
java -version          # OpenJDK 21.0.12.1 local
javac -version
 go version            # Go 1.23.2 local
bash katas/KATA-000029/tests/run.sh
```

`run.sh` compiles RED with `javac --release 21` and demands a behavioral assertion failure, compiles GREEN Java, runs native assertions, vets and runs the Go BFS oracle, and compiles/runs three real Java mutants against the oracle. The complete local output is in `evidence/local-run.txt`. Remote workflow: `.github/workflows/java-tic-tac-toe-kata.yml`; no CI result exists for this new source until a PR is created and the exact-head workflow actually executes.

## Provenance and Ninja

- Conceptual rules: https://kata-log.rocks/tic-tac-toe-kata (Kata-Log's own content explicitly public domain).
- No upstream starters, screenshots, fixtures or external code imported. Original Java/Go/Python/shell authored for this repository under MIT.
- Ninja v0.1.29 reviewed: `evidence/skill_review.md` (`no_change`). Local evidence does not establish causal benefit of the skill, independent review, or publication.
- The `catalog/candidates.json` transition is a proposal only (`evidence/catalog-transition.json`), to be applied on a new reviewable branch from the then-current `dev`, with fingerprint precondition and exact-head CI.
