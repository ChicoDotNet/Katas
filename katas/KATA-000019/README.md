# KATA-000019 — Parallel Change, expand-migrate-contract (Java 21)

Source concept: https://kata-log.rocks/parallel-change-kata. Kata-Log's own description is public domain; original starter code/tests from other repositories **not copied**. This kata implements its own teaching example under MIT.

The underlying change: an original ShoppingCart single-integer storage model evolves to store multiple integers while preserving compatibility with old consumers. In this original contract, deprecated setItem(value) REPLACES the former primary item, getItem() reads the primary item and raises on empty carts. New setItems(values) atomically replaces the collection, addItem(value) appends, getItems() returns an immutable defensive copy, and total() returns a long sum. The legacy API must remain operational until its callers have migrated; removal is outside this iteration. Negative or null items are rejected with no partial mutation.

Why Java: static method-level compatibility and deprecation warnings make the expansion phase concrete. Other candidates Swift/Kotlin could enforce typed immutable snapshots but Java is well suited to the demonstration and deterministic public API contracts.

Strict Parallel Change rule: production migration tests remain GREEN while expanding and migrating. A deliberately incorrect RED stub is compiled into a separate build directory solely to verify that the tests would detect a dropped list element. This does not imply introducing RED into a production migration.

~~~sh
cd katas/KATA-000019
mkdir -p /tmp/cart-green /tmp/cart-red
javac --release 21 -d /tmp/cart-green src/*.java tests/TestShoppingCart.java
java -cp /tmp/cart-green TestShoppingCart
python3 tests/differential.py /tmp/cart-green
javac --release 21 -d /tmp/cart-red tests/RedCart.java tests/TestShoppingCart.java
if java -cp /tmp/cart-red TestShoppingCart >/tmp/cart-red.log 2>&1; then exit 1; fi
grep -q 'bulk items retained' /tmp/cart-red.log
~~~

Local Java21: 11 fixed compatibility/isolation checks green, 400 Python differential command sequences green, and RED detects truncation of bulk items. Original operations and semantics are documented locally, not assumed identical to the externally linked shopping-cart starter. Provisional author difficulty 4/5, score 89/100, not calibrated.

Evidence: evidence/red.txt, green.txt, oracle.txt, ci.txt, skill_review.md.

## 2026-10-28 retroactive hardening — legacy ABI, atomicity and snapshots

The published Java 21 implementation remains unchanged. We added a **precompiled old client**: compile `tests/LegacyConsumer.java` only against `tests/legacy-api/ShoppingCart.java`, then run the same client bytecode with the current production class first on the runtime classpath. This checks JVM binary linkage, unlike merely recompiling an old source client. Native Java tests cover immutable snapshots, defensive copies, invalid-list failure atomicity (including a null *after* a valid prefix), integer-to-long sum boundaries, and 9,000 seeded mixed operations. Two compiled mutants deliberately expose a live mutable alias or commit partial state before rejecting an invalid element.

| Role | Language / strategy |
|---|---|
| Implementation (unchanged) | Java 21, expand-migrate-contract API |
| RED/GREEN and ABI | Java 21 native tests; separately precompiled legacy bytecode; compiled behavioral mutants |
| Original independent differential oracle (unchanged) | Python 3, 400 CLI sequences against a separate list state model |
| New complementary verification | Java 21 API state model, snapshot metamorphisms, failure injection, old-binary runtime linkage |
| Alternatives / common-mode risks | Source-only compile misses JVM binary linkage; another translated list simulator repeats data-structure assumptions; Java list model shares representation and is not a new independent oracle |

Run `bash tests/run-hardening.sh` from this kata directory; CI runs it after the existing RED/GREEN and Python differential suite. Local OpenJDK 21.0.12.1: 34,243 assertions across 150 histories / 9,000 steps; legacy binary linked and ran; both mutants compiled and failed as expected. See `evidence/compatibility-hardening-2026-10-28.md`. **This is additive hardening, not a new kata or published-state transition.**
