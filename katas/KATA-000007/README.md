# KATA-000007 — Tell Don't Ask, original C++20 refactoring laboratory

Source concept: https://kata-log.rocks/tell-dont-ask-kata. The original Kata-Log page is public-domain; code from the linked starter **was not copied**. The intentionally anemic legacy order model here and its refactored counterpart are independently authored, MIT-licensed teaching examples, not a refactor of Gabriele Tondi's original sources.

## Scope and contract
A draft order accepts valid lines (quantity > 0, nonnegative price in cents), may be approved only if nonempty, can be rejected while draft or approved, and ships only after approval. Shipped and rejected orders are terminal; rejected operations do not mutate state but are counted. The service computes subtotal and tax (0–2000 basis points, nearest-cent half-up) using integer cents. For the encapsulated `Order`, a valid-looking line is additionally refused *atomically* if its product, cumulative subtotal or tax-inclusive total would exceed signed 64-bit cents. Other real-world policies (refunds, tax jurisdiction, persistence and currencies) are outside scope; this is not a production order manager.

The original procedural LegacyOrder exposes mutatable fields. The \`Order\` class moves behavior behind methods and encapsulates state. Comparisons assert observable equivalence for defined flows; an independently written Python transition-table oracle supplements parity so matching defects do not go unnoticed.

## Why C++20?
C++ value semantics, \`std::vector\`, distinct state enum and explicit private members illuminate the difference between procedural mutable structs and encapsulated objects. Scala could offer richer algebraic types; Java has already been used for Ugly Trivia; C++ provides an idiomatic new contrast and gcc compilation without third-party packages.

## Reproduce
~~~sh
cd katas/KATA-000007
g++ -std=c++20 -Wall -Wextra -Werror -pedantic -I src tests/test_orders.cpp -o /tmp/order-test
/tmp/order-test
g++ -std=c++20 -Wall -Wextra -Werror -pedantic -I src src/cli.cpp -o /tmp/order-cli
python3 tests/differential.py /tmp/order-cli
g++ -std=c++20 -Wall -Wextra -Werror -pedantic -DKATA_RED -I src tests/test_orders.cpp -o /tmp/order-red
if /tmp/order-red > /tmp/order-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral invariant' /tmp/order-red.log
~~~

The deliberate RED preserves all types/API and returns wrong behavior, rather than failing compilation. Local compiler GCC 14.2.0; tests passed with \`-Werror\`; 420 independent cross-language scenarios. C++ tests exercise transitions, parity, terminal state, invalid commands, integer tax and rounding. Independent oracle enforces transition table separately.

Author's provisional difficulty 5/5 and rubric 89/100. Neither is independently calibrated. The original `LegacyOrder` procedural specimen still assumes bounded input; the encapsulated `Order` now rejects unrepresentable additions. This example deliberately does not implement a big-integer/money library.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md)

## 2026-10-29: monetary boundary and atomicity hardening (same KATA-ID)

**Problem and invariants.** The previous implementation could accept a line whose `quantity*cents` overflowed `int64_t`, and its `(subtotal*rate_bps+5000)` could overflow even for a representable subtotal. Signed overflow is undefined behavior in C++. For the encapsulated `Order`, an accepted line must preserve `0 <= subtotal <= INT64_MAX`, exact half-up tax and `subtotal+tax <= INT64_MAX`. A refused line must not alter the previous amount, tax, total or state; the refusal counter increases once. A zero-price line is still valid, and all terminal transitions retain their prior behavior. This is an intentional **contract extension**; the original anemic `LegacyOrder` remains a bounded-input teaching comparison, not a safe monetary API.

**Three principal-language alternatives, evaluated before CI.** C++20 remains the best implementation here because the learning objective is guarding signed machine arithmetic while preserving the existing value-semantic encapsulated aggregate and legacy contrast. Ada would expose numeric subtypes and checked exceptions more directly, but replacing the existing aggregate would lose the legacy-versus-domain comparison. COBOL has valuable decimal business arithmetic, but the issue is specifically C++ signed integer overflow and atomic mutation. VB.NET could use `Decimal` or `BigInteger` but would move away from this C++ refactoring experiment. No migration, new published kata or ornamental language switch.

| Responsibility | Language | Technique |
| --- | --- | --- |
| Implementation | C++20 | Checked multiplication/addition before mutation; quotient/remainder basis-point tax to avoid intermediate overflow; cached subtotal |
| RED/GREEN | C++20, GCC 14.2.0 | Behavioral RED; 28 native boundary assertions; `-Werror`, UBSan; existing lifecycle parity tests |
| Existing differential model | Python 3.13.5 | 420 transition-table scenarios (small bounded amounts) |
| New independent monetary oracle | Ruby 3.3.8 | Arbitrary-precision integer accounting computes exact total **before** applying the 64-bit representability limit; 1,212 scenarios |
| Complementary metamorphic oracle | Ruby 3.3.8 | 300 safe histories permuted and quantity-split: 600 monetary invariants, 900 executed histories |
| Fault sensitivity | C++20 + UBSan | Three compiled mutants: unchecked product, unchecked tax-inclusive total, and broken cached subtotal; 3/3 detected |

**Two different verification strategies.** Ruby's exact `Integer` arithmetic evaluates the mathematical contract without mirroring C++'s overflow-avoidance algorithm. Permutation/splitting tests instead check algebraic invariance of safely representable, nonnegative line sets; they do not depend on the expected numeric total from the Ruby model. The existing Python transition table covers different lifecycle failures. Shared risk: all three still assume the same half-up basis-point rule, and metamorphic invariance does not apply to overflowing histories where accepted subsets may depend on order. The Ruby model is an independent **arithmetic reference**, not a second proof of the business-state specification.

**Reproduce exactly (local evidence, not remote certification):**

~~~sh
cd katas/KATA-000007
bash tests/run_money_hardening.sh
~~~

The script runs original GREEN, original Python oracle, original behaviorally failing RED, UBSan boundary tests, Ruby exact oracle, Ruby metamorphic histories and three independently compiled faulty variants. It requires real `g++`, `ruby`, `python3`; GitHub Actions must execute the same script on the reviewed exact PR HEAD. New source/tests/workflow are authored under the repository MIT license, with no upstream starter or fixtures imported. Ninja OBS-008 is **confirmed locally**, not upgraded to a universal principle; no causal improvement or holdout result is claimed.
