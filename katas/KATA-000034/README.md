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

## Mutation hardening from first CI attempt

Initial exact-head CI at 93dd8edee9ddedd98ba04a62ef6999ec05952d0b ran genuine SWI-Prolog 9.0.4, native RED/GREEN and Go differential successfully, but the reversed green/ivory constraint **survived** because the two requested answers did not change. This exposed an oracle weakness, not a reason to accept the mutant. Added explicit positional invariants and independent full-world (all 25 positions) comparison; certification remains pending the new exact-head CI.

## Genuine runtime evidence and state

On PR #48 head `e4c167a5fa4b3078b07e36c08b8a166cfae2a8a2`, [GitHub Actions run 40365683668](https://github.com/ChicoDotNet/Katas/actions/runs/40365683668) completed **success** with SWI-Prolog 9.0.4 and Go 1.23.2. Behavioral RED rejected the stub; native plunit GREEN passed; Go exhaustive enumeration found exactly one world; Prolog/Go agreed on both answers **and all 25 positions**; two compiled Prolog constraint mutants were detected. This supports **GREEN on the PR branch only** and `development_complete=true`. The catalog metadata commit itself requires fresh exact-head CI before review/merge; **not verified or published**.
