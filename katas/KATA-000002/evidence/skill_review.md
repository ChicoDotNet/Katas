# Ninja lesson review — KATA-000002

Result: **incorporated** as a bounded observation; not a universally validated principle.
Compared with KATA-000003 (Fortran Game of Life):

- An independent oracle helped check state evolution for the pure Fortran transformation, and an independent reference + interaction spies helped verify the side-effecting PHP account boundary.
- New *candidate principle*: separate nondeterministic inputs (clock), mutable domain state (ledger), and presentation (statement formatter), then test public behavior using replaceable boundary interfaces. This **may** improve correctness and feedback at integration boundaries; no causal improvement in overall Ninja speed/transfer proven.
- Writing tests against ports surfaced a legitimate RED contract failure (missing ledger interactions) without requiring compilation to fail.
- Observed PHP's fixed-size integers require overflow guards. In real banking use monetary decimal types, currency semantics, durable ledgers, audit controls, and additional domain policies. Do not confuse this kata with production banking software.
- Do not assert that PHP beats COBOL, Java, F#, or other languages. This selection tests object-oriented boundaries and isolated infrastructure in PHP; Genkidama provided precedent for PHP CLI and PHP testing support.

Ninja v0.1.1 indexes the observation. Promotion to a consolidated rule requires additional independent examples and holdout evidence.
