# OBS-016 — 0–1 optimization and directions of in-place updates

The update order is part of an algorithm's *semantic correctness*: descending capacity in 1D dynamic programming protects the invariant that each inventory item is chosen at most once. Ascending updates silently convert this into an unbounded-knapsack model. Zero-weight items deserve an explicit boundary check. Value expectations must be audited independently: an initial hand-computed expected answer was false even though the implementation was correct; checking with a structurally distinct exhaustive oracle prevented weakening the algorithm to fit a bad test.

Context: Fortran DP, 8 behavioral scenarios and 500 Python enumerations locally. Bounds are explicitly limited. No claim of universal language choice or measured Ninja transfer acceleration.
