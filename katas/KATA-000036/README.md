# KATA-000036 — Poker Hand Rankings (Ruby)

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/poker (MIT: https://github.com/exercism/problem-specifications/blob/main/LICENSE). This is original Ruby, Python oracle and tests under MIT, without copying canonical tests or starters.

Each hand is exactly five different two-character cards. Ranks 2–9,T,J,Q,K,A; suits C,D,H,S. Sort by ordered category plus complete high-card/kicker comparisons, including ace-low wheel straight (five-high). Suits do not break ties. Return all equally best hands preserving input order. Empty set returns no winners. Duplicate or malformed cards in a single hand are invalid.

Ruby selected for tally and array comparison; a separate Python Counter and tuple-based oracle evaluates 760 independent cases. Complexity O(1) per fixed 5-card hand; O(H) for H hands.

Run: `cd katas/KATA-000036 && ruby -I src tests/test_poker.rb && python3 tests/differential.py src/cli.rb`. Behavioral RED `KATA_RED=1 ruby -I src tests/test_poker.rb` must fail. Local Ruby 3.3: 12 tests/15 assertions passed, 760 differential scenarios passed, RED behavioral. A random fixture initially contained a duplicated card; corrected generator and reran. Difficulty 5/5 and score 91/100 are provisional author assessments, not calibrated.

Evidence in evidence/ and Ninja OBS-022.
