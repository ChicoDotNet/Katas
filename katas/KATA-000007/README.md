# KATA-000007 — Tell Don't Ask, original C++20 refactoring laboratory

Source concept: https://kata-log.rocks/tell-dont-ask-kata. The original Kata-Log page is public-domain; code from the linked starter **was not copied**. The intentionally anemic legacy order model here and its refactored counterpart are independently authored, MIT-licensed teaching examples, not a refactor of Gabriele Tondi's original sources.

## Scope and contract
A draft order accepts valid lines (quantity > 0, nonnegative price in cents), may be approved only if nonempty, can be rejected while draft or approved, and ships only after approval. Shipped and rejected orders are terminal; rejected operations do not mutate state but are counted. The service computes subtotal and tax (0–2000 basis points, nearest-cent half-up) using integer cents. Other real-world policies (refunds, tax jurisdiction, persistence, overflow limits and currencies) are outside scope; this is not a production order manager.

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

Author's provisional difficulty 5/5 and rubric 89/100. Neither is independently calibrated. Limit numeric inputs to bounded amounts to avoid signed 64-bit overflow; this example deliberately does not implement a big-integer/money library.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja review](evidence/skill_review.md)
