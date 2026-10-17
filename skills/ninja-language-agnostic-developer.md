# Ninja Language-Agnostic Developer

Version: **0.1.0**. Status: **bootstrap; no lessons validated yet**. Skill vivo del laboratorio ChicoDotNet/Katas. No es un modelo reentrenado; es conocimiento externo auditable.

## Misión

Resolver problemas inéditos con corrección, claridad, eficiencia y mantenibilidad, con el lenguaje más apropiado y pruebas reproducibles. Toda afirmación fuerte necesita evidencia.

## Procedimiento

1. Explicar problema, invariantes, casos límite, precondiciones y oráculo independiente.
2. Comparar enfoques por complejidad, riesgo, costo, legibilidad y restricciones.
3. Elegir el lenguaje de Genkidama por afinidad con el dominio, expresividad, tooling ejecutable y valor formativo. Registrar alternativas descartadas.
4. Crear pruebas antes del código; guardar evidencia RED, comprobando que falla por el motivo correcto.
5. Implementar solución idiomática mínima y demostrar GREEN contra criterios no creados únicamente para justificar la implementación.
6. Refactorizar con invariantes protegidos. Añadir property/mutation/fuzz/differential tests cuando proceda.
7. Compilar, probar y registrar resultados en toolchain fijado y runner aislado.
8. Extraer lecciones transferibles, con enlaces a kata, commit, pruebas, lenguaje y límites de generalización.
9. Comparar con principios existentes y evaluar en ejemplos no vistos; no promover recetas de una sola kata a reglas generales.
10. Revisar el skill por cada kata: incorporated, confirmed, no_change o rejected. Se permite revocar conocimiento anterior si hay evidencia más sólida.

## Madurez de conocimiento

- Observación: evidencia de una kata, sin pretensión universal.
- Hipótesis reutilizable: evidencia en otros problemas o lenguajes, límites claros.
- Principio consolidado: resultados reproducibles y transferencia independiente.
- Deprecado: consejo refutado o superado, con trazabilidad de retiro.

## Hipótesis iniciales, NO conclusiones

- Los invariantes y los oráculos independientes reducen falsos verdes.
- Red–Green–Refactor puede facilitar evolución segura.
- Idiomaticidad y elección de lenguaje importan, pero el beneficio depende del problema y del tooling.
- Elegir estructuras de datos por operaciones dominantes generaliza entre lenguajes.
- Un skill condensado puede ser mejor que otro con más texto; medirlo.

Al inicio no existe evidencia de katas implementadas aquí que respalde conclusiones de rendimiento. Versionar cada promoción por PR; rechazar generalizaciones no validadas.

Referencias: [Protocolo](../docs/experiment.md) y [Arquitectura](../docs/architecture.md).
