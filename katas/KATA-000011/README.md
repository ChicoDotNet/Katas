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

Results locally: 11 fixed assertions, 1445 cross-language differential transitions and a genuinely behavioral RED. Kotlin 1.9.0 and JDK 21 (initial certification). The original publication remains unchanged; see evidence/ci.txt for its exact-head CI.

## Retroactive multi-day certification hardening — 2026-10-28

**Problem/invariants:** a daily rule may be correct on a bounded single-day grid but wrong after a long trajectory. Validate 30–365-day histories, monotonicity, immutability, saturation 0/50, concert expiration and time-step composition. The source code remains the same published Kotlin implementation; this is not a new kata or a migration.

| Responsibility | Language / technique | Why |
|---|---|---|
| Main implementation | Kotlin, immutable data-class transition | Existing published language; no replacement justified. |
| RED/GREEN | Kotlin 1.9, native assertions and 2,250 trajectories | Exercises real repeated calls, bounds, category-specific monotonicity and split/rejoin trajectories. |
| Original one-step reference | Python, 1,445 differential transitions | Retained for backwards compatibility; limited to mostly short horizons. |
| New independent oracle | Ruby 3.3, **closed-form counting of time intervals** | Calculates final state in O(1) arithmetic without translating the Kotlin daily branches. |
| Additional reference self-check | Ruby, semigroup property over 1,000 splits | Guards the closed-form reference's interval arithmetic; does not replace differential comparison. |
| Fault injection | Kotlin mutant affecting Aged Brie on day -31 | Demonstrates detection of a defect beyond the old one-step reference domain. |

**Oracle alternatives compared:** (A) a Ruby day-by-day rule table would duplicate Kotlin branching and share boundary errors; rejected as the primary new oracle. (B) closed-form counts of pre-expiry and expired days, and three disjoint ticket windows, yield a structurally independent reference; selected. (C) metamorphic split/rejoin and category invariants are complementary, but can miss a consistently wrong daily rule; retained as native properties. Ruby is preferable to Go here because concise integer interval algebra and built-in deterministic sampling make the independent formula auditable; Haskell would express pure transitions elegantly but could encourage the same recursive daily formulation. No language was selected to satisfy a diversity quota.

**Shared-error risk:** both models use the *declared* rules and assume the same convention that `sellIn == 0` is expired at the start of the day. They could therefore share a specification misunderstanding. The kata is an original clean-room contract, not a verification of a third-party starter. No claim of transfer improvement or production equivalence is made.

**Actual local commands** (Debian 2026-10-28; Kotlin 1.9.0, JDK 21, Ruby 3.3.8):
~~~sh
cd katas/KATA-000011
bash tests/run_trajectory.sh
~~~

Observed: **929,640 Kotlin trajectory assertions**, **6,001 Kotlin/Ruby closed-form comparisons**, **1,000 Ruby reference semigroup checks**, **1/1 temporal mutant detected**. Original RED, 11 GREEN assertions and 1,445 Python differential transitions were also rerun. See [hardening evidence](evidence/trajectory-hardening-2026-10-28.md). New CI requires an exact-head run of `.github/workflows/kotlin-katas.yml` before the hardening PR can be merged; the old publication's status is unchanged until then.

## Ninja evidence
Optional domain categories and time discontinuities need explicitly documented semantics. The 2026-10-28 long-horizon mutation shows that single-day bounds may miss a later defect, but one mutant is not a general causal demonstration of Ninja's effectiveness. Ninja v0.1.29 reviewed, outcome `confirmed`; no skill change.

Provisional author score 92/100, difficulty 5/5. Not calibrated. [RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracles](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja observation](evidence/skill_review.md).
