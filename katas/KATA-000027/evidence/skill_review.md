# KATA-000027 — Ninja review (2026-10-30)

- Ninja version: 0.1.29; conclusion: no_change.
- Implementation: Ruby finite-state immutable values; native Ruby Minitest; Go prefix-count mathematical oracle; observed player-swap metamorphism.
- RED: parseable intentionally wrong Ruby stub fails native tests for behavior, not syntax.
- GREEN: Ruby 33 assertions; Go 34,772 actual CLI histories; 3/3 mutated Ruby implementations killed.
- Concrete finding: independent Go prefix-count model exposed a real error-precedence discrepancy (AAAAZ: terminal already reached vs unknown player). Ruby now checks terminality before the next player's validity; native regression added.
- Limitations: shared tennis semantics, bounded enumeration, no starter refactor, no independent holdout, no evidence that Ninja caused better outcomes. No new principle proposed.
- Rights: no third-party starters or fixtures imported; only public-domain Kata-Log conceptual page; original MIT code.
- Remote CI: pending, not certified or published.
