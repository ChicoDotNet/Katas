# KATA-000037 — Reactive Cells (JavaScript)

Source: https://github.com/exercism/problem-specifications/tree/main/exercises/react (MIT repository license: https://github.com/exercism/problem-specifications/blob/main/LICENSE). This is reactive programming, NOT React UI. All implementation and test source here authored independently under MIT; no canonical fixtures copied.

Input cells hold safe integers. Computed cells depend only on earlier cells, so the graph is acyclic and already topologically ordered. Each input change recomputes a complete stable state before invoking callbacks **once per changed computed cell**. Unchanged values do not notify. Failed computations revert state. Unsubscribe is supported and callbacks may not recursively initiate writes. Computed functions must return safe integers. The testing CLI supports sum, max and product modulo 997 (numeric generator bounded); the public API accepts any pure integer function.

JavaScript chosen for first-class callback functions and no external UI framework; Python is an independent recompute-from-scratch oracle. Cost O(V+E) per update (no dirty-graph optimization). Production function callbacks that throw after dispatch begin are not reversible; this kata does not promise transactional callback effects.

Run: `cd katas/KATA-000037 && node --test tests/test_reactor.mjs && python3 tests/differential.py src/cli.mjs`. Behavioral RED: `KATA_RED=1 node --test tests/test_reactor.mjs` should fail a behavioral case. Local validation: 10 fixed behavioral tests and 360 independent DAG histories passed; confirmed behavioral RED. Score 93/100 and difficulty 5/5 are **author provisional**, not calibrated.

Evidence files in evidence/ and Ninja review OBS-021.

## Extensión políglota de verificación — 17-oct-2026

**Haskell modelo funcional**, `tests/reactive_haskell.hs`, recálculo por instantáneas puras de 180 DAGs y comparación de eventos con el reactor JavaScript. Aporta evaluación determinista sin mantener el mismo programador de callbacks. Se contemplaron OCaml (ADTs), Elm (reactividad declarativa) y Haskell; Haskell concentra la comprobación en valores inmutables. Workflow `haskell-reactive-kata.yml`.

No se aumenta el número de katas publicadas por esta extensión. Mantener evidencia histórica y exigir CI exact-head.
