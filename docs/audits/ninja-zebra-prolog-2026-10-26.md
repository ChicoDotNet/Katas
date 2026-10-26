# KATA-000034 — Zebra Puzzle audit (2026-10-26)

- ID/fingerprint retained: KATA-000034 / exercism-spec-zebra-puzzle.
- Rights: Exercism problem-specifications exercises/zebra-puzzle/instructions.md under MIT LICENSE, Exercism (2014, 2019, 2021). Canonical-data inspected only, not imported; no starter/fixtures copied.
- Domain: finite constraint satisfaction, five houses, five bijections, fifteen clues, unique complete assignment.
- Languages evaluated BEFORE CI: Prolog (winner), Haskell, Ada, Go; reasons and counterfactual in kata README.
- Independent strategies: CLP(FD) propagation+labeling versus Go exhaustive concrete permutations with staged pruning. Native plunit, mutation gates and Go uniqueness test.
- Genkidama reference: ChicoDotNet/Genkidama dev .github/workflows/polyglot.yml functional job installs swi-prolog-nox on Ubuntu 24.04; eng/ci/registry.json includes src/Functional/Prolog/.
- Executed locally: go test -race tests/oracle.go tests/oracle_test.go PASS; go run tests/oracle.go PASS. SWI-Prolog unavailable locally; RED/GREEN/differential/mutants NOT CERTIFIED.
- Ninja v0.1.29: no_change pending runtime; no causal attribution.
- Existing PRs #45/#46/#47 independent; no migration/publication. dev catalog retains discovered.

## CI-driven rework
- Initial workflow 40365338544 on HEAD 93dd8edee9ddedd98ba04a62ef6999ec05952d0b: real SWI-Prolog 9.0.4 installed, behavioral RED, native GREEN and Go answer-level differential passed; mutation `reverse_green` survived, so CI **failed**.
- Root cause: both requested answers could remain unchanged when a clue was violated. This demonstrated that answer-only differential checks are insufficient for a unique-world puzzle.
- Follow-up commits added native direction/position invariants and comparison of the full 25-position assignment with the independently enumerated Go world. Must be re-executed on the new HEAD before any GREEN claim.

## Certified native execution (before metadata commit)
- [Workflow run 40365683668](https://github.com/ChicoDotNet/Katas/actions/runs/40365683668) on exact head `e4c167a5fa4b3078b07e36c08b8a166cfae2a8a2`: completed success; native SWI-Prolog 9.0.4 RED/GREEN, Go 1.23.2 -race and full-world differential, both mutants killed.
- First failing run 40365338544 exposed an answer-only oracle weakness; the corrective full-world oracle is now executed, not merely proposed.
- Catalog metadata update is a **new head** requiring exact-head CI; status `green` only in review branch, no published claim.
