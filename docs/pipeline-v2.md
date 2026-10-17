# Development/CI overlap — experiment extension 2026-10-17

The new pipeline is **single-author serial development with asynchronous CI**. A kata must have an implemented solution, verified local RED, GREEN, a structurally independent oracle, authorship/provenance notes, and Ninja review **before** work begins on the next. It may then set `development_complete: true` and stay `green` until remote CI has reported results.

GitHub-hosted CI may run in parallel with creation of the following kata. This saves wait time but MUST NOT be taken to mean concurrent or incomplete kata development.

## Catalog scanning

Every source scan adds all new canonical candidate records with stable IDs, source URLs and provisional fingerprints/difficulty, status `discovered`. The scan manifest records how many were considered, unique and rejected. Rights and rubric are audited **per candidate** before marking eligible. Scan records are append-only and independently reviewable. This first expanded scan covers the 31 exercises listed by Kata-Log, including the four prior published ones.

## Promotion

`green + development_complete` = independently tested locally, GitHub CI pending. `verified` = GitHub CI green and evidence. `published` = integrated reviewed PR and explicit skill review. Already-published count is NOT affected by overlapping work.

If the current PR's CI fails, fix it and/or open a follow-up corrective PR. Do not hide the failure, and do not merge a partially tested branch.

## Throughput policy: do not poll away the iteration

**Engineering WIP is sequential, CI WIP is concurrent.** In each hourly execution, continue developing the next distinct eligible kata immediately after the previous kata reaches `green + development_complete`, aiming for up to nine locally completed katas per run. "CI is still running" is not a stopping condition or a reason to burn remaining work time refreshing workflow statuses.

- Check CI at the beginning to recover failures, and again opportunistically at a batch checkpoint/end. Avoid repeated tight polling. Handle actual failures when discovered; do not hide red evidence or merge unverified work.
- Commit logical, independently testable kata increments with reproducible results. Avoid moving a shared PR head purely to trigger another CI cycle. Prefer a stable CI checkpoint and continue development on a separate feature branch or unpublished local commits when appropriate.
- GitHub CI may verify a previous kata while new source is written, but `verified` and `published` require evidence for the actual reviewed head. Never credit local-only results to the published total.
- Measure separately **active engineering time**, **time awaiting CI**, **CI duration**, and **time spent polling CI**. The goal is more verified useful output per working window, not higher reported throughput by conflating states.
- Resume eligible work while the slowest JVM/Swift/etc. jobs run. Finish a kata's local tests, independent oracle, provenance and Ninja note *before* beginning the next, and keep idempotent checkpoints to reconcile agents and updated branches.

## Git tooling: no dependency on GitHub CLI

The hourly agent must **never require `gh`**. First detect tools, checkout, remotes and credentials:

1. With a valid workspace, use ordinary `git` (`status`, `fetch`, `log`, `diff`, `switch`, `commit`, `push`) for source/version operations on its own feature branch. Verify the remote state, avoid rewriting someone else's work and never force-push.
2. Prefer the connected GitHub tools for PR creation, reviews, CI checks, or source access when Git alone cannot perform the action. Connector use is also valid without any local checkout.
3. If Git credentials or write capability are missing, record what actually failed and pivot to a usable connector. Absence of `gh` **is not a blocker**. Absence of working Git and connector write access is a real blocker, not permission to claim unpushed changes.
4. Never require installing an external CLI to continue; do not invent commits, build outcomes, pushes or PR numbers.

This policy applies to unattended hourly executions and interactive work alike.

## Stable main cadence (every 18 published)

Mandatory dev→main promotion milestones: 18, 36, 54, 72, 90, then each further multiple of 18 after the separate pilot gate. Keep main-only commits through reconciliation and use exact-head CI; promotion CI does not block development of the next kata. See docs/promotion-main.md and tools/release_milestones.py.

## Elegir lenguaje ANTES de la infraestructura

Antes de consultar qué CI existe en Katas, evaluar el dominio e invariantes de la kata y comparar al menos tres candidatos técnicamente relevantes de Genkidama. Documentar en el README qué hace interesante el lenguaje ganador, las alternativas y el contrafactual frente a otro lenguaje habitual. Workflow existente nunca puntúa como ventaja semántica. Configurar herramientas y CI después de seleccionar el lenguaje, adaptando la familia correspondiente de Genkidama. No forzar novedad por sí sola: un lenguaje frecuente puede ganar si demuestra una mejor afinidad. Si no se logra instalar el compilador, dejar checkpoint y reportar bloqueo; jamás inventar GREEN o cambiar de lenguaje sin rehacer el razonamiento. Documento canónico: docs/language-selection.md.

## Meta aspiracional 53 lenguajes y reemplazos retroactivos

Procuramos descubrir katas de enorme interés en cada uno de los 53 lenguajes Genkidama, sin cuotas ni repartos equitativos; repetir sin límite el lenguaje más apropiado cuando la afinidad lo justifique. Si se descubre que una kata ya verificada/publicada sería mejor en otro lenguaje, permitir reemplazo sobre **la misma KATA-ID** con nueva justificación, RED/GREEN/oráculo/CI y PR de migración; conservar solución anterior hasta certificación y su historial recuperable por Git. Actualizar Ninja y metadatos; no sumar otra kata publicada ni mover hitos de main por el reemplazo. Cobertura de lenguajes significa implementaciones principales publicadas en el estado actual, no lenguajes que se mencionaron o intentaron históricamente. Reglas detalladas en docs/language-selection.md.

## Oráculos independientes sin monopolio de Python

Consultar docs/oracle-selection.md. Antes de escribir pruebas para cada nueva kata, decidir separadamente tests nativos y modelo de referencia (mismo u otro lenguaje). Seleccionar primero técnica matemática/algoritmo/propiedades independientes y luego lenguaje ideal; comparar al menos dos estrategias, no recurrir a Python por reflejo ni cambiar de lenguaje solo por aparentar diversidad. Documentar riesgo de defectos compartidos, toolchain reproducible, RED/GREEN/oráculo efectivamente ejecutados y exact-head CI. Si no puede ejecutarse un oráculo necesario, no marcar development_complete. La modernización retroactiva de pruebas no incrementa el conteo de katas publicadas.
