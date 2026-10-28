# OBS-013: expand-migrate-contract without temporary production RED

In a compatibility-sensitive API, add the new representation and accessors while preserving legacy entrypoints; only remove old accessors after consumers migrate and versioning allows. Expose immutable snapshots to prevent uncoordinated mutations. Keep all production tests green throughout each migration step. A separate, deliberately defective replacement demonstrates that the tests detect information loss; it is NOT a reason to break the working migration. A Python model demonstrates parity across 400 mixed legacy/new command sequences.

These are original local semantics; the Kata-Log starter's specific contract is not presumed. This evidence supports one bounded learning observation, not a measured acceleration of Ninja.

## 2026-10-28 — OBS-013 confirmed, bounded

A separately compiled Java legacy-only API shell plus a precompiled consumer tests actual JVM linkage after expansion. This complements, rather than replaces, the existing Python list-model differential oracle. Native Java fault injection covers partial mutation on invalid bulk input, snapshots and integer overflow. Two compiled mutants are rejected. No production code change, no generalized causal claim; see `compatibility-hardening-2026-10-28.md`.
