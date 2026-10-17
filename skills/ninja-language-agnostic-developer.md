# Ninja Language-Agnostic Developer

Version: **0.1.5**. Status: **experimental observations; transfer not yet validated**. Skill vivo del laboratorio ChicoDotNet/Katas. No es un modelo reentrenado; es conocimiento externo auditable.

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

## Observaciones trazables (todavía NO principios consolidados)

- **OBS-001, KATA-000003 (Fortran, Life):** un núcleo de transformación puro, combinado con un oráculo diferencial en otro lenguaje, permitió verificar la actualización simultánea de una matriz finita. [Evidencia](../katas/KATA-000003/evidence/skill_review.md).
- **OBS-002, KATA-000002 (PHP, Banking):** al separar reloj, libro de movimientos y renderizado detrás de puertos pequeños, un doble de prueba detectó una implementación que ignoraba interacciones y un oráculo independiente examinó 251 historiales. Este patrón puede aumentar la verificabilidad de sistemas con efectos, pero todavía falta evaluación en otros problemas y en holdouts. [Evidencia](../katas/KATA-000002/evidence/skill_review.md).
- **OBS-003, KATA-000002 (PHP, Banking):** usar enteros de rango fijo para cantidades monetarias obliga a prevenir overflow y no resuelve los problemas de decimales, divisas, persistencia o política bancaria; el contrato de una kata no sustituye requisitos de producción.

- **OBS-004, KATA-000001 (Java, original trivia):** antes de refactorizar un sistema con estado y salida mezclados, inmovilizar fuentes de entrada y conservar una transcripción reproducible puede proteger cambios estructurales. Pero equivalencia en trazas observadas no equivale a corrección de toda la especificación; complementar con un oráculo independiente y entradas adversariales. El ejemplar legado se creó desde cero, sin copiar el código GPL enlazado. [Evidencia](../katas/KATA-000001/evidence/skill_review.md).

- **OBS-005, KATA-000004 (Erlang, Gossiping Bus Drivers):** en una simulación síncrona de difusión de conocimiento, calcular primero todas las uniones usando el estado anterior evita propagación instantánea indebida entre lugares diferentes. Formalizar el índice temporal (visita inicial = 1), la monotonía del conocimiento y el criterio de convergencia es indispensable para que el contrato no dependa de intuiciones sobre el tiempo. Contrastar bitmasks Erlang contra conjuntos Python permite comprobar 2378 escenarios sin reutilizar la misma estructura de representación. **Esta observación está sujeta al CI y no prueba ventajas de Erlang ni de Ninja en problemas nuevos.** [Evidencia](../katas/KATA-000004/evidence/skill_review.md).

- **OBS-006, KATA-000005 (Go, Mars Rover):** en APIs con operaciones secuenciales, distinguir **errores de comando** (rechazo completo antes de cualquier efecto) de **eventos del entorno** (obstáculo: progreso parcial intencional) y declarar la geometría de los bordes. Una variante de código para probar RED debe conservar los tipos compartidos sin generar fallos de compilación que oculten defectos de conducta. [Evidencia](../katas/KATA-000005/evidence/skill_review.md). Observación individual, no principio consolidado.

- **OBS-007, KATA-000006 (Ruby, Unusual Spending):** al aplicar umbrales porcentuales fijos a importes exactos, comparar productos cruzados de enteros en unidades menores (`2×actual ≥ 3×anterior`) evita errores de frontera del punto flotante. Distinguir explícitamente gastos previos inexistentes y cero; inyectar fuente de pagos y emisor de avisos para comprobar cambios de mes, especialmente de enero a diciembre. [Evidencia](../katas/KATA-000006/evidence/skill_review.md). Observación bajo validación, no garantía general de mayor velocidad.

**Hipótesis transversal bajo estudio:** hacer explícitas las fronteras entre estado, nondeterminismo y presentación facilita construir oráculos independientes para problemas de distintas familias. Dos ejemplos no prueban que acelere a Ninja ni que generalice universalmente. Evitar convertirla en regla prescriptiva hasta validación.

## Hipótesis iniciales, NO conclusiones

- Los invariantes y los oráculos independientes reducen falsos verdes.
- Red–Green–Refactor puede facilitar evolución segura.
- Idiomaticidad y elección de lenguaje importan, pero el beneficio depende del problema y del tooling.
- Elegir estructuras de datos por operaciones dominantes generaliza entre lenguajes.
- Un skill condensado puede ser mejor que otro con más texto; medirlo.

Al inicio no existe evidencia de mejora longitudinal por uso del Ninja. Versionar cada promoción por PR, mantener holdouts aislados y rechazar generalizaciones no validadas.

Referencias: [Protocolo](../docs/experiment.md) y [Arquitectura](../docs/architecture.md).
