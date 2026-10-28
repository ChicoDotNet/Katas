# KATA-000058 audit — 2026-10-28

- Source: Exercism Ledger conceptual contract (MIT description SHA a53e5c15e3e6f5f6a62a8ea6be82e3072477baae; MIT license SHA 6813d6298df9a46da6485050e8a5fcd61ab79879).
- Canonical metadata SHA 0902bab57d178dc9cd9dd5eabaf3ddc52f476272 consulted only. No starter, canonical fixtures, or copied tests.
- Explicit scope caveat: this is an original formatter, not a refactoring of the upstream bad starter.
- Implementation C++20: integer cents, Gregorian date validation, deterministic ordering and Unicode-character-aware currency column. Native tests C++20, independent oracle Ruby BigDecimal/Date, metamorphic input permutation, Python mutation runner only.
- Local toolchains GCC 14.2.0, Ruby 3.3.8, Python 3. GREEN 75,027 assertions; 960 differential; 320 metamorphic; 7 malformed; 2/2 compiled mutants. RED compiled and failed behaviorally. ASan/UBSan enabled.
- Rework: corrected euro width (3 UTF-8 bytes vs one visible character), native test expectations, Ruby subprocess encoding, random test domain to stay within fixed 13-column amount width.
- Ninja v0.1.29: confirmed, not modified. No causal claim. Active engineering time not measured; unknown.
- State: GREEN LOCAL, no PR, no CI exact-head, no independent review, no merge or publication.
