# KATA-000034 — Zebra Puzzle (Prolog / Go)

**Status: Prolog NOT CERTIFIED** until an authentic SWI-Prolog runtime executes RED/GREEN, mutations and the independent Go differential check. Do not change catalog status to green solely because Go passes.

## Contract and invariants
Five houses, five bijective categories (color, nationality, beverage, pet, hobby). Fifteen positional/equality clues determine one complete assignment. Observable questions: who drinks water and who owns the zebra. layout/1 enumerates complete assignments, solution/2 yields both answers. House positions are 1–5.

## Language decision BEFORE checking CI
- **Prolog + CLP(FD)** (chosen): finite relations, all-different constraints and adjacency map directly to the domain. Needs genuine SWI-Prolog runtime.
- **Haskell**: pure permutations and algebraic types; explicit search/pruning obscures declarative constraints.
- **Ada**: ranges and strong types; imperative backtracking less direct for relational search.
- **Go**: efficient exhaustive enumeration, better suited as a structurally independent oracle.
Counterfactual: always using C#/Java/Python loses the distinction between declaring relations and enumerating concrete worlds. No claim Prolog is universally faster.

## Three independent language roles
- Implementation: SWI-Prolog library(clpfd), all_distinct, labeling.
- RED/GREEN: SWI-Prolog plunit; RED behavioral stub must fail.
- Oracle: Go 1.23.2 enumerates permutations and prunes worlds in stages; no CLP(FD). It independently establishes uniqueness and answers, then compares a real Prolog execution.
- Structural/mutation: complete-assignment uniqueness, all-different invariants, 120 distinct Go permutations, two mutated constraints.
CLP(FD) versus concrete enumeration is structurally different, but both encode the same clue text; common specification mistakes remain possible.

## Reproducible commands
```bash
cd katas/KATA-000034
go test -race tests/oracle.go tests/oracle_test.go
go run tests/oracle.go
bash tests/run.sh
```

**Observed locally 2026-10-26:** Go unique solution norwegian/japanese, Go tests passed. SWI-Prolog absent locally and DNS blocked installation; therefore Prolog RED/GREEN, differential runtime and mutations NOT EXECUTED locally. CI must run before development_complete=true.

## Provenance and rights
Concept and clues: https://github.com/exercism/problem-specifications/tree/main/exercises/zebra-puzzle; upstream MIT license https://github.com/exercism/problem-specifications/blob/main/LICENSE (Exercism copyright 2014, 2019, 2021). Original code/tests; no third-party starter or fixtures imported. See docs/audits/ninja-zebra-prolog-2026-10-26.md.

## Limits
One fixed puzzle, not a generic Einstein puzzle parser. No causal Ninja performance claims. Independent holdouts still needed.
