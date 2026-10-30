# KATA-000026 encoding boundary hardening — 2026-10-30

Independent manual adversarial input exposed an interface defect: malformed UTF-8 bytes (`ff`, Base64 `/w==`) were silently decoded to the Unicode replacement character and yielded `ERR:command`, rather than the documented `ERR:encoding`. Malformed Base64 already returned `ERR:encoding`.

**Correction:** `Main.kt` now uses a UTF-8 `CharsetDecoder` with `CodingErrorAction.REPORT`, catches `CharacterCodingException`, and rejects invalid byte sequences before any task state is touched. `tests/cli_contract.py` checks three real Kotlin CLI executions: valid UTF-8, malformed Base64, malformed UTF-8. Local command `python3 tests/cli_contract.py .build/app.jar` passed all three after recompilation. The original behavior was reproduced before the fix.

The Go event-replay oracle (701 real Kotlin scenarios) and compiled Kotlin mutation controls (3/3) were rerun after the fix and passed. Python in this new test only validates CLI encoding, not domain expected values. Remote CI must execute the complete runner at the new exact SHA; previous CI head is superseded.
