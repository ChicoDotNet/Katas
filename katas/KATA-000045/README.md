# KATA-000045 — Two Bucket (Go 1.23)

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/two-bucket, MIT https://github.com/exercism/problem-specifications/blob/main/LICENSE. Original Go solution, tests and Python oracle under MIT without imported upstream fixtures.

Two different positive capacities (1–30), target 1..max capacity, start bucket 1 or 2. First action always fill designated bucket. Subsequent operations fill, empty, or pour until source empty/destination full. Reject no-ops. Never reach the state where initial bucket is empty and other bucket full. Output minimum moves, goal bucket, other bucket contents and witness action/state trace. If unreachable, return possible false. For an endpoint containing target in both buckets, select starting bucket.

Go BFS with state-key parent records finds a minimum path, O(cap1×cap2) states. A separate Python layer-frontier model checks minimum distance; a step-by-step witness validator checks every recorded transition and the forbidden state independently.

Local Go 1.23: initial goal, 4-step pour, unreachable and input rejection tests, 1200 independent shortest-path/witness cases and behavioral RED using KATA_RED=1. The CLI was separated into cmd/buckets to avoid mixed packages. Run `cd katas/KATA-000045 && go test ./... && go build -o /tmp/buckets-cli ./cmd/buckets && python3 tests/differential.py /tmp/buckets-cli`; behavioral RED: `KATA_RED=1 go test ./...` must fail. Provisional author 5/5 difficulty and 92/100 score, not calibrated.

Evidence under evidence/ and Ninja OBS-025.

## Independent witness-label audit (17 Oct 2026)

Audit discovered that the original differential checked minimum moves and legal **states** but did not check the semantic meaning of each **action label**. `tests/witness.py` now independently interprets named actions against state transitions and checks the compulsory first fill. `tests/test_witness_validator.py` uses a known valid path and **five intentionally corrupted witnesses** to prove that mislabeled operations/intermediate states are rejected. The original layer-based shortest-distance oracle remains intact. This is test hardening, **not a new kata or evidence of faster Ninja transfer**; CI must recertify the exact changed HEAD.
