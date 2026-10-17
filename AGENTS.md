# Katas: contrato para agentes

1. Leer README, docs/experiment.md, docs/source-policy.md y skills/ninja-language-agnostic-developer.md.
2. Nunca copiar enunciados, código, tests, imágenes o inputs de terceros sin licencia comprobada del **artefacto específico**; conservar atribuciones.
3. Nunca fingir estados red, green, verified o published; enlazar evidencia reproducible. Tests diseñados por el mismo agente no reemplazan oráculos independientes.
4. Escoger el lenguaje mejor adaptado desde el catálogo Genkidama, justificando alternativas. No imponer cuotas por lenguaje.
5. Durante el piloto aplicar hardest-first **entre candidatas elegibles**. En el corte de 90 publicadas ejecutar gate; si falta evidencia, no continuar automáticamente.
6. Cada kata requiere revisión del Ninja con resultado incorporated, confirmed, no_change o rejected. Observaciones individuales no son principios universales.
7. Preservar RED fallido por el motivo correcto, GREEN, revisión independiente, refactorización y CI.
8. Una rama kata/ID-descripcion por desafío y PR hacia dev usando **squash merge**. dev a main mediante PR de promoción certificada y **squash merge**; después, sincronización main a dev con un **merge commit** exclusivamente si no cambia el árbol. No escribir directamente en ramas protegidas lógicamente.
9. Código desconocido se ejecuta solo en runners efímeros sin secretos ni permisos privilegiados, idealmente sin acceso a la red. No usar runners self-hosted persistentes para códigos públicos ajenos.
10. Si se agota la ejecución, conservar checkpoint; nunca aprobar ficticiamente por cumplir cadencia.
11. Revisar Genkidama Learn/eng/ci/registry.json, run-family, adapters y Polyglot CI antes de crear soporte de un nuevo lenguaje; adaptar con pruebas y licencias.
12. Optimizar calidad y transferencia demostradas, no líneas de código, tokens ni cantidad de reglas.

13. **Pipeline overlapping**: una kata solo libera el siguiente trabajo cuando pruebas de comportamiento, oráculo, notas, revisión de Ninja y ejecución local han terminado, con `development_complete: true` y CI pendiente. No confundir con published. Cuando CI llega, verificar/promover independientemente; si falla, corregir la kata anterior sin perder el trabajo posterior.
14. Cada escaneo debe ser **aditivo, sin IDs/fingerprints duplicados**: persistir nuevas candidatas `discovered` con URL, revisión de fuente, fecha y riesgo de reutilización. Reservar la auditoría completa para antes de promover a eligible.
15. No bloquear la siguiente autoría esperando Actions; no hacer merge/published sin verde. Un PR de lote puede contener commits atómicos por kata, preservando orden y trazabilidad de validación local.

16. **No `gh` dependency**: check for ordinary `git`, checkout, remote and credentials. Use `git` for branches/commits/push when functional and connected GitHub tools for PR/CI or where Git is inaccessible. Missing GitHub CLI is never a blocker. Verify every claimed remote write.
17. **CI polling is not the work queue**: once a kata is locally complete with reproducible RED/GREEN/oracle/Ninja evidence, develop the next while previous CI runs. Check workflows at reasonable checkpoints, never repeatedly poll slow JVM/Swift runners instead of writing the next eligible kata. Preserve exact-head CI certification before merge/publication.

18. **Gobernanza de ramas**: seguir `docs/governance/delivery.md`. Dependabot envía PR a `main` (rama predeterminada); un PR de promoción certifica el `dev` HEAD exacto antes de squash, y el PR posterior `main → dev` solo sincroniza ancestros sin cambios de contenido. No promocionar ramas o PR con CI pendiente o rojo.
