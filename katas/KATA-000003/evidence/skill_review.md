# Ninja evidence review — KATA-000003

Conclusion: **confirmed** (no universal new rule promoted). Ninja version used: 0.1.0.

- The original behavioral RED stub returns a wholly empty board; the fixed-pattern assertion **block stable** fails. Replacing it with an independent generation calculation turns the six fixed-pattern tests GREEN.
- A separate Python set/dictionary oracle (distinct algorithmic structure) matches Fortran on 677 boards. Both were authored for this project and still require independent review for benchmark-quality claims.
- Finite edges (exterior dead) must be a **documented contract choice**; toroidal wrapping is a valid alternative kata variant, not an implicit default.
- Fortran's built-in 2D arrays and pure functions make explicit input immutability and simultaneous state updates. Julia and Python are plausible alternatives; no evidence yet one is objectively faster or more maintainable.
- Validate outputs in a second language when there is material risk that language-specific array semantics hide a defect. This is a case observation rather than a universal Ninja rule.
- No inference yet about longitudinal Ninja skill improvement; one implementation supplies evidence of correctness only.
