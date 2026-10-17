# OBS-024 — Generate AST first to validate reconstruction

For tree reconstruction, generate the intended tree first, derive both traversals and assert the reconstructed structure equals the intended one. A second rebuilding algorithm is a weaker independent oracle because it can share the same partition error. Membership equality alone does not guarantee that distinct traversals describe a consistent tree. Bounded observation only; no transfer claim.
