# KATA-000002 — Banking Kata / PHP 8.4

Original specification reference: https://kata-log.rocks/banking-kata (Kata-Log page declares its own contents public domain, see its footer). No outside starter code, example fixture files or tests were copied; this implementation and its tests are original MIT contributions.

## Contract and scope

Account exposes deposit(int), withdraw(int), printStatement(): string. Positive integral amounts change the balance. The statement reports each transaction's effective date, signed amount, and running balance, newest operation first. Output formatting is locally defined and tested. A negative account balance is permitted in this exercise because the source does not require overdraft rejection. Real production financial systems need explicit policy, decimal/currency types, compliance and persistence.

## Why PHP?

The challenge is architectural: observable interactions between a public Account boundary, a clock, a ledger and presentation. PHP 8.4 supports strict scalar types, typed ports, immutable transaction records, lightweight CLI verification and test doubles without external dependencies. COBOL could model monetary batch logic, while Scala/Java could showcase type-system and mocking frameworks. PHP supplies useful contrast with the previous Fortran 2D matrix kata; no language is ranked superior without controlled tests.

## RED → GREEN → independent verification

~~~sh
cd katas/KATA-000002
# Expected failure: grep specifically for the contractual violation.
if KATA_RED=1 php tests/behavior.php >/tmp/bank-red.log 2>&1; then exit 1; fi
grep -q 'FAIL: outside-in ledger interactions' /tmp/bank-red.log
php tests/behavior.php
python3 tests/differential.py
php -l src/Bank.php
php -l src/cli.php
~~~

RED uses a deliberately nonfunctional Account stub, demonstrating that acceptance tests detect missing recorded transactions; tests do **not** need to fail because source files are absent. GREEN is nine behavioral checks: captured port interactions, renderer delegation, statement acceptance, print idempotence, invalid amounts, overflow and empty statement. Differential tests generate 250 seeded histories plus an empty one against a Python algorithmically independent ledger oracle; one invalid scenario tests the CLI's error handling.

The CLI takes JSON array entries with date (dd/mm/yyyy), type (deposit/withdraw) and amount (positive integer), and prints its statement. The protocol is an independent test adapter, not an extension to Account's public interface.

Provisional scoring: transfer 18/20, depth 17/20, oracle 13/15, TDD 15/15, novelty 7/10, pedagogy 7/10, portability 4/5, maintenance 4/5 = **85/100**; preliminary single-reviewer assessment.

Evidence: [RED](evidence/red.txt), [GREEN](evidence/green.txt), [oracles](evidence/oracle.txt), [CI](evidence/ci.txt), [Ninja review](evidence/skill_review.md). Only mark verified after GitHub-hosted CI passes. Publish only after PR is merged to dev.
