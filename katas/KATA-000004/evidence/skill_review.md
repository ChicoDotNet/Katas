# Ninja observation OBS-005 — provisional

Candidate result: **incorporated as a bounded observation only if remote CI passes**.

The interesting invariant is information monotonicity. Every driver starts with their own unique gossip, each stop merges all knowledge from the previous snapshot, and no one forgets. A complete gossip set is a fixed point, but the number of visits until every driver reaches it depends on the time-varying **meeting graph**, not on the static union of all routes.

Lessons:
- Define the time origin explicitly. Counting the initial stop as visit **one** matches the canonical example (5); a zero-based minute index would yield 4 without being mathematically inconsistent.
- Compute all changes from a shared previous state, then commit together. An in-place driver-by-driver propagation loop can permit knowledge to travel across multiple distinct stops within one minute, producing premature success.
- For small N (here at most 16 drivers), a bitset encodes a monotone join of gossip identities with bitwise OR. This is one synchronous simulation in Erlang, **not evidence of distributed runtime/message-passing fault tolerance**.
- Compare a distinct Python set-based model to avoid matching the exact same implementation bug.

Limits: Inputs capped at 16 drivers, 64 positions per route and 480 encounters. No evidence yet that Ninja improves accuracy or speed on unseen problems. No generalized rule is claimed from this single kata.
