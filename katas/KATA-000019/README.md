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
