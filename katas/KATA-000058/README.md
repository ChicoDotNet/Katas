# KATA-000058 — Ledger (original C++20 formatter + Ruby independent model)

**Status:** GREEN LOCAL ONLY. No remote PR, no exact-head GitHub CI, no independent reviewer, and **NOT published**. Original implementation of the formatter contract; **not a genuine refactor of Exercism's deliberately bad starter**. This distinction must remain explicit when evaluating transfer of refactoring skills.

## Domain, invariants and boundaries

The exercise formats an accounting ledger of ISO-dated entries, descriptions and **integer cents** for USD/EUR and en_US/nl_NL. The order is chronological, then lexical description, then signed cents ascending. Date validation uses Gregorian leap years. Locale selects date order, grouping, decimal separator, labels and negative formatting; currency selects only the symbol. The output has 10-character date, 25-character description and 13-**Unicode-character** monetary fields. Descriptions longer than 25 characters are truncated to 22 plus `...`. The original, narrow, printable-ASCII description contract is documented; this is **not** a Unicode-grapheme formatter. Unsupported currency/locale, malformed dates, malformed TSV and amounts exceeding column width are rejected. Formatting is atomic: invalid input never yields partial ledger rows.

No floating point is used in production; negative INT64_MIN magnitude can be computed without signed overflow and then rejected as too wide. The CLI reads tab-separated date, description and integer cents, and prints one row per line. Tabs/newlines inside descriptions are unsupported by this CLI contract.

## Language comparison **before** workflow selection

- **C++20 (selected):** value objects with signed fixed-point cents, strict input validation, deterministic sorting and explicit byte-vs-Unicode-width accounting. These are meaningful production correctness questions in financial reporting; native sanitizers exercise UB and memory safety. C++ is not selected because of an existing workflow.
- **COBOL:** strongest conventional affinity for decimal accounting and report layout; an excellent future main-language candidate. However, this particular task is a from-scratch replacement rather than an authentic COBOL legacy refactor, and local GnuCOBOL is absent. Do not claim COBOL was tested.
- **Ada:** decimal fixed types and constrained records could express amount and locale contracts more statically, but this host lacks GNAT; merits a separate future kata with authentic compiler.
- **Go:** int64 cents and straightforward sorting are good, but this version exposes more of the byte-vs-character and validation tradeoffs in C++20. No quota preference.

## Three independent roles and verification strategies

| Role | Language | Technique |
| --- | --- | --- |
| Production | C++20 / GCC 14.2 | Integer-cent formatting, comparator sort, Gregorian validation, locale policy |
| Native RED/GREEN | C++20 / GCC 14.2 | Behaviorally failing compiled stub; 75,027 native assertions; ASan + UBSan |
| Independent differential model | Ruby 3.3 / BigDecimal | Decimal numeric arithmetic, `Date.iso8601`, key-based sorting, regex grouping and Unicode-aware `String#length` |
| Metamorphic oracle | Ruby 3.3 | Permutation invariance under input reordering (320 distinct executions) |
| Mutation | Python 3 orchestration only | Compile actual C++ mutants and require behavioral test failure, 2/2 |

**Alternatives compared:** a second C++ implementation of the same integer-cents grouping would share structural mistakes; Ruby BigDecimal + Date uses different arithmetic and parsing libraries. Metamorphic permutation invariance detects nondeterministic or input-order-sensitive sorting independently of formatting arithmetic. Shared locale conventions and expected output labels remain common-mode risks; native fixed examples and mutation checks mitigate but do not eliminate them. Python is **not** the oracle.

## Rights and provenance

Concept and contract derived from Exercism `problem-specifications/exercises/ledger/description.md`, blob `a53e5c15e3e6f5f6a62a8ea6be82e3072477baae` (MIT repo license blob `6813d6298df9a46da6485050e8a5fcd61ab79879`). Canonical-data metadata was consulted to understand locale/format semantics (blob `0902bab57d178dc9cd9dd5eabaf3ddc52f476272`) but **no canonical fixtures or starter code were copied**. All code, assertions, randomized data and logs here are original and MIT-licensed under the Katas repository. This is a formatter kata, not evidence that a legacy refactor was executed.

## Reproduce

`cd katas/KATA-000058 && bash tests/run.sh`

Executed locally on 2026-10-28 using GCC 14.2.0, Ruby 3.3.8, Python 3: RED fails for expected behavior; GREEN 75,027 native assertions with ASan/UBSan; 960 independent Ruby differential cases, 320 input-order metamorphic comparisons, 7 malformed-input rejections; 2/2 compiled mutants killed. Repeat execution recorded in `evidence/`. No claim of GitHub CI success until the workflow runs against an exact PR SHA.

## Governance and experiment

Existing KATA-ID and fingerprint retained. No publication count increment. Ninja v0.1.29 reviewed: `confirmed`; no skill modification, no causal throughput claim. Candidate difficulty and score are provisional and author-calibrated, not independent. No holdout has been used; maintain the 90-published gate. No main promotion until milestone 36 with its own audited PR.
