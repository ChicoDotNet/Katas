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
