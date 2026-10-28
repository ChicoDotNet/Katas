# KATA-000011 — Multi-day hardening checkpoint, 2026-10-28

- Base: dev `0d97c338cb8702265ad6fda4381cbd9336197f61` (reverify before merge).
- Published implementation `src/Inventory.kt` unchanged, original blob `b01d8f4c0b639f940b265c115892fb3ae7087b45`.
- Kotlin compiler: `kotlinc-jvm 1.9.0`, JRE 21.0.12. Ruby 3.3.8, Python 3.13.5.
- Existing RED compiled, failed for `ordinary before expiry` behavior; existing GREEN passed 11 fixed assertions; original Python oracle passed 1,445 transitions.
- `bash tests/run_trajectory.sh`: 929,640 native Kotlin assertions across 2,250 histories (including 30–365 days); 6,001 real Kotlin/Ruby closed-form comparisons; 1,000 reference semigroup checks; 1/1 compiled Kotlin mutant detected by differential oracle (Brie day -31).
- Retrabajo: initial Ruby script had an invalid `require 'random'`; removed and reran successfully. No production changes.
- Rights: original clean-room MIT implementation and tests. New files are original MIT; no upstream starter, fixtures or third-party data imported.
- Ninja v0.1.29 (`32cb01f2e088453762f5c79239d1f11e6991bf83`), review `confirmed`, no update to skill. One mutation does not establish general transfer.
- This checkpoint is **LOCAL ONLY** until exact-head CI and independent PR review. Do not claim a new publication, migration or recertified hardening from this file alone.
