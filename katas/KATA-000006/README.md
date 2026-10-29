# KATA-000006 — Unusual Spending (Ruby 3.3)

Source: https://kata-log.rocks/unusual-spending-kata (Kata-Log own public-domain material). No TestDouble/upstream starter code or test fixtures were imported; all code in this kata was written independently under MIT.

## Contract and precision
Category-scoped transaction amounts use **integer cents**. Given payments for two months, aggregate sums per category and flag current spending **at least 50% more** than the previous month. This is evaluated by exact cross-product `2*current >= 3*previous`, not binary floating point. Categories absent from the previous month with *positive* new spending are flagged; zero compared to zero is never flagged. This zero-baseline rule is a deliberate local interpretation because the exercise leaves division by zero ambiguous. Only recognized categories are permitted (entertainment, golf, groceries, restaurants, travel).

A `Service` injects a payment source and mail sender, uses explicit calendar-month boundaries (including January→December), formats one deterministic message only when there are alerts and does nothing when there are none. This is a demonstration of testable boundaries, not a payments-grade money framework.

## Why Ruby?
The problem emphasizes service composition, category grouping, immutable payment values, flexible test doubles and calendar boundaries. Ruby 3.3 with minitest supplies this without external gems. R would be a natural candidate for statistical anomaly scoring, but the source is a fixed deterministic per-category threshold, not a statistical test; COBOL would be interesting for legacy batch processing, but Ruby better exposes outside-in seams for this kata. The reference oracle is authored independently in Python.

## Reproduce
~~~sh
cd katas/KATA-000006
ruby -I src tests/test_spending.rb
python3 tests/differential.py src/cli.rb
if KATA_RED=1 ruby -I src tests/test_spending.rb > /tmp/spending-red.log 2>&1; then exit 1; fi
grep -q 'Failure:' /tmp/spending-red.log
~~~

Local results: 7 tests, 23 assertions, all passed; 334 independently generated/reference-checked scenarios; deliberate RED exits nonzero. `ruby -v` was 3.3.8. Remote CI pending. Tests cover threshold equality and lower boundary, new category, zero, aggregation, sorted results, date rollover, spy mail delivery and no mail when no alert.

## Evidence
[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [skill review](evidence/skill_review.md). Author-only provisional rubric: 91/100, difficulty 5/5, not independently calibrated.

## Additive calendar and fault hardening (2026-10-29)

The existing Ruby implementation and Python differential reference are unchanged. The new Ruby Minitest suite verifies explicit previous-month arithmetic across 11 years × 12 months × 3 days, injected source/mail failures, 500 exact threshold boundaries and 300 deterministic metamorphic histories (permutation, payment splitting and amount scaling). It tests failure paths and calendar selection that the Python output oracle does not cover. The Ruby mutation harness compiles and detects wrong-month, off-by-one threshold and omitted-delivery mutants. The original Python 334-case category oracle is retained; this is not a second translated aggregation oracle. No new kata or language migration.

Implementation and RED/GREEN: Ruby 3.3; original independent oracle: Python 3; complementary calendar/fault/metamorphic verifier and mutation harness: Ruby 3.3. Considered COBOL for batch, R for statistical scoring, and Java for service boundaries; none provides a compelling reason to replace the published Ruby behavior for this hardening. Run `bash tests/run_calendar_hardening.sh`; see [audit](evidence/calendar-hardening-2026-10-29.md) for rights, risks, executed commands and Ninja v0.1.29 review. No CI certification claimed for this local checkpoint.
