# KATA-000047 — Variable Length Quantity in PHP 8.4

Source concept: [Exercism VLQ](https://github.com/exercism/problem-specifications/tree/main/exercises/variable-length-quantity), [MIT repository](https://github.com/exercism/problem-specifications/blob/main/LICENSE). Original PHP implementation, fixtures and independent Python oracle here are MIT; **no canonical data or starter code copied**.

Unsigned 32-bit integers are encoded into groups of seven bits in big-endian order. All output groups except the last have the continuation bit set. Decode concatenated sequences of VLQs with explicit rejection of negative/out-of-range input, noncanonical leading zero continuation, unterminated values, groups longer than five bytes, and overflow above 2^32−1. The empty sequence is valid. For reproducibility the API accepts integer values, not floating-point aliases.

PHP 8.4 was selected for typed API boundaries, bitwise operations and explicit exception paths; Python's independent reference uses divmod and positional arithmetic instead of the PHP shifting loop. Alternative Go/C fit bit streams equally well.

~~~sh
cd katas/KATA-000047
php -l src/VLQ.php
php tests/test_vlq.php
if KATA_RED=1 php tests/test_vlq.php >/tmp/vlq-red.log 2>&1; then exit 1; fi
grep -q 'FAIL behavioral assertion' /tmp/vlq-red.log
python3 tests/differential.py src/cli.php
~~~

Local: 16 fixed boundary/error checks GREEN, RED compiled and failed due to wrong decoding; 1,003 independently generated encode/decode/malformed cases PASS. A bad initial expected concatenation was corrected before GREEN. Time O(inputBytes+outputBytes), bounded integers; reject noncanonical alternatives by design. Provisional author difficulty 4/5, score 90/100; no independent calibration.

[RED](evidence/red.txt) · [GREEN](evidence/green.txt) · [oracle](evidence/oracle.txt) · [CI](evidence/ci.txt) · [Ninja observation](evidence/skill_review.md).

## Extensión políglota de verificación — 17-oct-2026

**Ada + Rust implementaciones de contraste**: `tests/vlq_ada.adb` y `tests/vlq_rust.rs` codifican/decodifican valores u32 con rechazo de representaciones no canónicas y overflow; `tests/vlq_crosscheck.mjs` contrasta ambos contra la interfaz PHP original en casos deterministas. Ada aporta manejo explícito de dominios enteros y GNAT con comprobaciones; Rust, enteros sin signo y multiplicación checked. C y Go también serían plausibles pero enseñan menos sobre estos contratos. Workflow `ada-rust-vlq-kata.yml`. PHP sigue siendo implementación principal.

No se aumenta el número de katas publicadas por esta extensión. Mantener evidencia histórica y exigir CI exact-head.
