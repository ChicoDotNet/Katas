# OBS-013: expand-migrate-contract without temporary production RED

In a compatibility-sensitive API, add the new representation and accessors while preserving legacy entrypoints; only remove old accessors after consumers migrate and versioning allows. Expose immutable snapshots to prevent uncoordinated mutations. Keep all production tests green throughout each migration step. A separate, deliberately defective replacement demonstrates that the tests detect information loss; it is NOT a reason to break the working migration. A Python model demonstrates parity across 400 mixed legacy/new command sequences.

These are original local semantics; the Kata-Log starter's specific contract is not presumed. This evidence supports one bounded learning observation, not a measured acceleration of Ninja.
