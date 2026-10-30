# Ninja review — 2026-10-30

KATA-000025 / `custom-delimiter-parser-negative-validation`.
Ninja v0.1.29; decision **no_change**. Unicode grapheme scanner in Swift and AST-first Go generator provide a structurally different check of delimiter boundaries. Evidence: 30 native GREEN assertions, 2,948 actual differential/metamorphic executions, 3/3 compiled mutations killed. This is a local observation only; no independent holdout, causal claim, or change to Ninja. Review remains subject to exact-head CI and external review before publication.

Rights: only Kata-Log's own public-domain conceptual page used; code and fixtures independently authored MIT. Main risk: AST generator and production parser share specification conventions; random cases are seeded and malformed grammar coverage is bounded.
