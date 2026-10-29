# KATA-000007 — overflow/atomicity hardening checkpoint

Date: 2026-10-29. Base `dev`: `0d97c338cb8702265ad6fda4381cbd9336197f61`. Original `orders.hpp` blob: `af297a1d34c7cfa58567183d739400366efbc848`. All four original source/test/README blobs were verified locally against GitHub before modification. No external starter or fixtures imported; new tests and code authored under MIT.

RED: native `test_money_limits.cpp` compiled successfully with `g++ -std=c++20 -Wall -Wextra -Werror -pedantic` against the original header, exited 1 with `FAIL behavioral invariant: reject quantity times cents overflow`. An initial draft test produced an unused-function compilation warning; corrected **before** recording behavioral RED. This distinction matters: the compiler failure was not RED evidence.

GREEN: the updated `Order` rejects line-product overflow, subtotal overflow and tax-inclusive total overflow before mutating state. `tax_of` uses quotient/remainder rather than multiplying the full subtotal by basis points. The intentionally anemic legacy specimen retains its bounded-input scope. No new kata, language migration or publication claim.

Local toolchains: GCC 14.2.0, Ruby 3.3.8, Python 3.13.5. Run `bash katas/KATA-000007/tests/run_money_hardening.sh` from repository root. The workflow must run this same command on its exact head; **remote CI not yet certified at checkpoint creation**.

Ninja: OBS-008 **confirmed** at a single kata. Guard arithmetic *before* state mutation and check the resulting tax-inclusive total; a lifecycle-only oracle can miss numeric undefined behavior. Not incorporated as a universal principle; no independent holdout, time-gain or causal skill-effect evidence.
