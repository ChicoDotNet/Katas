# KATA-000011 — Gilded Rose in Kotlin

Reference: https://kata-log.rocks/gilded-rose-kata (Kata-Log's own public-domain description). No upstream starter, fixture or external code imported. Original MIT clean-room solution, not a refactor of Emily Bache's starter.

Model: one pure item-to-item transition per day. Ordinary products lose 1 quality before expiry and 2 afterward; Conjured items lose twice that; Aged Brie gains 1/2; Backstage passes gain 1/2/3 when input sellIn is above 10, at most 10, or at most 5 respectively, and drop to 0 at expiry; Sulfuras always retains quality 80 and does not age. Nonlegendary qualities are limited to 0..50. Input is immutable.

Language: Kotlin data classes and deterministic rules. Alternatives Pascal/COBOL and Fortran are suitable but would emphasize record processing rather than pure value copies. Python's independent reference uses a separate rule table.

Commands:
~~~sh
cd katas/KATA-000011
kotlinc src/Inventory.kt tests/InventoryTest.kt -include-runtime -d /tmp/gilded-test.jar
java -jar /tmp/gilded-test.jar
kotlinc src/Inventory.kt src/Main.kt -include-runtime -d /tmp/gilded-cli.jar
python3 tests/differential.py /tmp/gilded-cli.jar
kotlinc tests/InventoryRed.kt tests/InventoryTest.kt -include-runtime -d /tmp/gilded-red.jar
if java -jar /tmp/gilded-red.jar > /tmp/gilded-red.log 2>&1; then exit 1; fi
grep -q 'ordinary before expiry' /tmp/gilded-red.log
~~~

Local Kotlin 1.9 and JDK 21: 11 fixed assertions, 1445 cross-language differential transitions and a genuinely behavioral RED. The test oracle does not copy a starter implementation. Provisional score 92/100, difficulty 5/5; these are author assessments pending rubric calibration.

Evidence: red.txt, green.txt, oracle.txt, ci.txt and skill_review.md under evidence/.
