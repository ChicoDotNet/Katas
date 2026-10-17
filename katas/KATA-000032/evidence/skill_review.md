# OBS-014: exploit arithmetic invariants to prune combinatorial search

The solver considers choices column by column, using the carry and each output digit to reject contradictory assignments before exploring subsequent columns. Distinct-digit injection and leading-zero rules are maintained as backtracking invariants. This is not equivalent to naively enumerating all permutations: pruning reduces exploration without changing the solution set.

The important discovery in test design is that **single-letter words are allowed to be zero**, although multi-digit leading letters are not. An initially incorrect unit test assumed otherwise and was corrected against the exercise's explicit instructions before claiming GREEN. This distinguishes repairing the oracle/spec from modifying production code to please an invalid test.

The independent oracle enumerates all injective assignments for 84 selected puzzles, and compares satisfiability plus arithmetic validity rather than one particular solution when multiple exist.

This is a *bounded observation* from one Python kata. No general measured improvement in Ninja's speed, precision or transfer has yet been shown.
