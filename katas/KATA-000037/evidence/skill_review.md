# OBS-021 — Stable-state callbacks in reactive DAGs

Recompute all dependent values to a stable state before dispatching callbacks, and compare previous versus new stable values to prevent duplicate intermediate notifications in diamond graphs. Generate independent recomputation oracles rather than implementing a second nearly identical event scheduler. Respect safe-integer contracts in randomized scenarios: unbounded products can invalidate the test itself. One local implementation does not prove transfer or improved Ninja speed.
