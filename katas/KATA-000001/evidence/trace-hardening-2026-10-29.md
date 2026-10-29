# KATA-000001 — trace hardening checkpoint, 2026-10-29

- Base reference: dev 0d97c338cb8702265ad6fda4381cbd9336197f61; original source/tests blobs matched GitHub exactly: TriviaCli.java ec0f949f, TriviaLegacy.java 545c08d8, TriviaRefactored.java 6c810188, TestTrivia.java 6a406356, differential.py 69ddc49c, RedStub.java 1b66a310, fixture e765f74b.
- Toolchains actually run: javac 21.0.12.1, Ruby 3.3.8, Python 3.13.5, git 2.47.3.
- Original RED compiled and failed on refactored behavioral golden master mismatch; GREEN original 3 assertions PASS.
- Original Python forward oracle PASS: 196 scenarios x legacy/refactored + 5 invalid input cases.
- New Ruby event monitor PASS: five deterministic cases x two modes, 550 assertions, via bash katas/KATA-000001/tests/run_trace_hardening.sh.
- Three compiled Java mutants detected: wrong round-robin increment, wrong question sequence, score reset on move. All rejected behaviorally.
- Technique: Python generates expected transcript; Ruby validates emitted events and metamorphic alpha-renaming/prefix invariants. Shared authored rules remain a common-mode risk.
- Rights: new Ruby tests, Bash runner, workflow, and docs are original MIT. Original Java sources are original MIT. GPL upstream starter is referenced only, not imported.
- Ninja OBS-004: confirmed; no skill edit, transfer or causal inference.
- No new scan, catalog change, publication or migration. Independent review and exact-head CI required before merge.
- Reliability: optional extended 17-case monitor passed in an earlier local run but a repeat on 2026-10-29 timed out in Open3; it is not a required CI gate. Five deterministic cases and mutation suite passed again in this run. Investigate the intermittent long-case hang separately; do not count the timed-out rerun as success.
