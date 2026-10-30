# Ninja review — KATA-000018 (2026-10-30)

Ninja version 0.1.29; decision: **no_change**. Perl streaming CLI + Test::More RED/GREEN; Ruby independent AST-first transcript oracle; observed double-reversal metamorphism. Distinct structural reference strategy chosen before toolchain/CI.

Concrete findings: Unicode process boundaries required Perl `Encode::decode` for ARGV and Ruby explicit UTF-8 for subprocess output. Empty command history must not accidentally send one empty message. All fixed with actual process regression. Three Perl mutants were syntax-checked and rejected for **behavioral oracle mismatches**, not runtime or import errors.

Limitations: shared Unicode grapheme semantics, case-sensitive palindromes, bounded histories, no external holdout or causal skill evaluation. No generalized principle promoted. Kata-Log own page public domain; no third-party starters imported; original MIT code.

Local RED/GREEN/oracle/mutations passed. CI exact-head, independent review, and publication remain pending.
