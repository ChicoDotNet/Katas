# Katas: contrato para agentes

1. Leer README, docs/experiment.md, docs/source-policy.md y skills/ninja-language-agnostic-developer.md.
2. Nunca copiar enunciados, código, tests, imágenes o inputs de terceros sin licencia comprobada del **artefacto específico**; conservar atribuciones.
3. Nunca fingir estados red, green, verified o published; enlazar evidencia reproducible. Tests diseñados por el mismo agente no reemplazan oráculos independientes.
4. Escoger el lenguaje mejor adaptado desde el catálogo Genkidama, justificando alternativas. No imponer cuotas por lenguaje.
5. Durante el piloto aplicar hardest-first **entre candidatas elegibles**. En el corte de 90 publicadas ejecutar gate; si falta evidencia, no continuar automáticamente.
6. Cada kata requiere revisión del Ninja con resultado incorporated, confirmed, no_change o rejected. Observaciones individuales no son principios universales.
7. Preservar RED fallido por el motivo correcto, GREEN, revisión independiente, refactorización y CI.
8. Una rama kata/ID-descripcion por desafío, PR a dev, no escribir directamente en main. Dev a main por promoción revisable.
9. Código desconocido se ejecuta solo en runners efímeros sin secretos ni permisos privilegiados, idealmente sin acceso a la red. No usar runners self-hosted persistentes para códigos públicos ajenos.
10. Si se agota la ejecución, conservar checkpoint; nunca aprobar ficticiamente por cumplir cadencia.
11. Revisar Genkidama Learn/eng/ci/registry.json, run-family, adapters y Polyglot CI antes de crear soporte de un nuevo lenguaje; adaptar con pruebas y licencias.
12. Optimizar calidad y transferencia demostradas, no líneas de código, tokens ni cantidad de reglas.
