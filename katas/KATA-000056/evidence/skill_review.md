# OBS-020 — Bounded FIFO overwrite contracts

Reject-on-full and evict-oldest are different policies and must be distinct operations. Ring indices depend on head after reads and wraparound; test both capacity limits and clear/reuse, and compare with a structurally independent deque rather than another ring index implementation. Compiler -Werror warnings require correction before attributing GREEN. This is a single C11 observation, not a demonstrated cross-task Ninja advantage.
