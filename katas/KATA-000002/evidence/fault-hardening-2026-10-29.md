# KATA-000002 — fault-injection hardening, 2026-10-29

This is an additive hardening of an already-published kata. The production PHP code, original RED/GREEN suite, Python differential oracle, KATA-ID, and catalog state remain unchanged. Kata-Log's own conceptual description is recorded as public domain; this does not license linked third-party starters, fixtures, or datasets. All new tests, source mutations, and runner code are original MIT contributions.

## Domain and language decision

Contracts: reject invalid amounts before clock/ledger side effects; one clock observation per accepted operation; propagate clock/ledger/formatter failures; reject integer overflow and underflow before append; keep snapshots immutable. PHP 8.4 is retained for its existing typed port interfaces and strict scalar checks. COBOL is attractive for batch/decimal accounting but would obscure PHP dependency failures; Ada would emphasize ranges but require disproportionate migration; Java would expose typed exception ports but not the published PHP behavior. Reimplementing in a habitual language would erase the original experiment's boundary.

Implementation: PHP 8.4, existing port-based account and integer ledger. RED/GREEN: native PHP behavior and fault-injection spies. Original independent reference: Python 3, 251 ledger histories. Complementary verification: native PHP dependency failures, integer-boundary atomicity, immutable snapshots. Python in the mutation harness edits source text only and is not an additional oracle.

Compared two structurally different verification approaches: a second ledger simulator would duplicate the existing Python model, while fault injection and boundary invariants target errors invisible to output-only histories. The latter was selected. Risk: the fake ledger does not model a third-party ledger that partially mutates before throwing; cross-service rollback is not established. This is not a production decimal/currency implementation.

## Reproducible local evidence

Run from katas/KATA-000002:
- php -l src/Bank.php
- php tests/fault_injection.php
- python3 tests/differential.py
- bash tests/run_fault_hardening.sh

PHP 8.4.24 and Python 3.13.5: 1,034 native assertions passed; 251 original differential histories passed; 3/3 compiled behavioral mutants were rejected: invalid-before-clock, double-clock, and no-overflow. Original behavioral RED failed as expected and GREEN passed nine assertions. Initial runner attempt lacked the original differential.py in the temporary checkout; restoring its exact Git blob resolved this setup issue. Remote CI on the PR exact head remains required.

Ninja v0.1.29 review: confirmed OBS-002/OBS-003, no skill modification. No causal improvement claim; transfer requires independent holdouts. Repeated boundary tests are deterministic, not random.
