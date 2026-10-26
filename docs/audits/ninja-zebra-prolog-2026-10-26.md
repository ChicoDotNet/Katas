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
