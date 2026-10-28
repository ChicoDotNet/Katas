# Ninja v0.1.29 — KATA-000033 independent AST hardening

Status: **confirmed locally; no skill change**. Review date: 2026-10-28.

Existing OBS for Forth: compiling/fixing earlier references preserves semantics
under later definition changes; token interpreters in different languages can
still share lexical and stack assumptions. This run adds an AST-first Go
reference, immutable expression trees and explicit alias/shadowing metamorphic
witnesses, but does not validate transfer to another task.

- Production TypeScript source unchanged, exact Git blob `12703cb84342f34231fb48d020de1fb247d11221`.
- Native TypeScript RED compiled and failed behaviorally; GREEN and Python
  original differential executed locally.
- Go AST-first oracle: 2,117 cases, including 2,100 generated and 17 fixed.
- Three independent compiled semantic mutants were rejected.
- Remaining risks: shared truncation contract, bounded AST magnitude,
  untested general Forth syntax and possible generator blind spots.
- No causal speed/quality claim for Ninja; no published-count increment.
- Remote CI and independent review are **pending**.
