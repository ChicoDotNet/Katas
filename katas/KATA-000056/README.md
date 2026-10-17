# KATA-000056 — Circular Buffer in C11

Reference: https://github.com/exercism/problem-specifications/tree/main/exercises/circular-buffer (MIT license: https://github.com/exercism/problem-specifications/blob/main/LICENSE). Original source, tests and oracle in this repo are MIT, without copying upstream starter files or canonical data.

A fixed-size FIFO has two write policies: ordinary write rejects when full, while overwrite evicts the oldest element. Read removes the oldest. Clear resets logical state; snapshot returns items in FIFO order. Capacity 1–128, no heap allocation, operations write/read O(1), snapshot O(n). This implementation is a synchronous data structure, not a thread-safe concurrent queue. C11 chosen to expose ring index/modulo invariants. A Python collections.deque model is the independent oracle.

Reproduce from katas/KATA-000056: build src/ring.c with tests/test_ring.c under cc -std=c11 -Wall -Wextra -Werror -pedantic, build src/ring.c with src/cli.c and run python3 tests/differential.py against the CLI, then build tests/red_stub.c with tests/test_ring.c and check the resulting executable fails an overwrite assertion. Local: 12 deterministic checks, 600 independently compared histories, genuine behavioral RED. The initial CLI failed a compiler warning for misleading indentation; fixed before differential verification. Author-only provisional difficulty 4/5 and score 90/100. Remote CI pending.

Evidence: evidence/red.txt, green.txt, oracle.txt, ci.txt and skill_review.md.
