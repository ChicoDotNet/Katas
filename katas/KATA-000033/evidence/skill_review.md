# OBS-014 — Forth snapshot definitions and behavioral compatibility

Status: locally GREEN, transfer NOT established.

Words may be redefined, even builtin words. If definitions retain only raw symbolic references, later redefinitions retroactively change earlier functions. Capturing referenced behavior when a definition is made gives deterministic semantics and allows extending previously-defined words safely. A Python token-expansion reference produced the same behavior as TypeScript typed instructions across 816 scenarios.

State boundaries matter: a persistent interpreter carries stack and dictionary across calls, while a fresh evaluator must isolate both. Explicit errors for underflow, zero division, invalid names and numeric overflow prevent accidentally treating malformed input as valid output.

Limits: only an arithmetic/stack Forth subset and safe JS integers; no conclusion about compiler JIT performance, general interpreter security, or Ninja's future speed. This is original code, not an implementation copied from Exercism.
