# KATA-000006 — calendar, metamorphic and dependency-failure hardening

Date: 2026-10-29. **Local checkpoint only, not remotely certified.** The published Ruby production implementation, original Minitest suite and independent Python oracle remain unchanged. No new kata or language migration.

## Domain and language comparison

Contract: 50% category threshold using integer cents; month boundaries must be canonical month starts and handle December→January; read failures and mail failures propagate; no mail on no alerts; stable results under splitting, scaling and reordering payments. Retain **Ruby 3.3** for existing typed-by-validation value objects, Date and Minitest service boundaries. Alternatives: **COBOL** for decimal batch reporting (less suited to injected Ruby service collaborators), **R** for statistical outlier detection (misleading because threshold is deterministic), **Java** for typed dependency boundaries (would replace the subject under test). No choice made for workflow convenience. Rewriting the published service in a habitual language would lose the actual boundary behavior and create migration risk without evidence.

| Role | Language | Technique |
| --- | --- | --- |
| Implementation | Ruby 3.3 | Existing pure category detector + calendar service |
| RED/GREEN | Ruby 3.3 Minitest | Original seven tests, plus calendar/failure tests |
| Original independent oracle | Python 3 | 334 generated category cases |
| Complementary reference | Ruby 3.3 | Explicit previous-month arithmetic, metamorphic permutation/splitting/scaling, injected collaborator failures |
| Mutation harness | Ruby 3.3 | Three compiled and behaviorally rejected variants |

Two different verification strategies were considered: another Python/Ruby category aggregation oracle would share the detector's grouping assumptions; metamorphic properties and explicit calendar/fault witnesses target defects in composition and time windows that output-only tests miss. The original Python reference remains useful for independent aggregate expected values. Risk: the new tests are authored by the same agent, and do not establish external mail delivery atomicity or real-world monetary semantics.

## Executed evidence

Ruby 3.3.8 / Python 3.13.5. Original RED fails by Minitest behavioral failure; original GREEN 7 tests / 23 assertions PASS. Python differential 334 cases PASS. New Ruby tests: **3 runs / 4,398 assertions PASS**. Three source mutations compile (`ruby -c`) and fail for the intended behaviors: wrong previous-month direction, threshold strictness, and omitted email delivery. `bash tests/run_calendar_hardening.sh` PASS. Local code and original tests verified byte-for-byte against current dev Git blob SHAs.

No external starter, fixtures or tests imported. Kata-Log's own conceptual text is public domain according to its site; this does not license third-party links. New files are original MIT. Ninja v0.1.29 review: **confirmed** OBS on service ports and threshold boundaries, no skill modification or causal claim. Next: create a feature branch from the **then-current** dev SHA, integrate workflow, run exact-head CI and obtain independent review before merge. Published count stays unchanged.
