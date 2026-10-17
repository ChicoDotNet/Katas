# OBS-028 — Worker-private state and deterministic reduction

For concurrent map/reduce workloads, keep every worker's mutable map private, then merge on a single goroutine. This reduces race hazards and makes outputs deterministic regardless of work assignment. Complement behavior tests with the race detector and a sequential independent Counter, while documenting simple rune lowercase versus full Unicode casefold. A passing race detector does not constitute mathematical proof of race freedom; no longitudinal Ninja improvement has been established.
