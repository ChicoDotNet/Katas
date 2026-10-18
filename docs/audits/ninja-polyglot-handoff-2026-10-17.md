# Continuidad — extensiones políglotas y endurecimiento de diez katas

**Fecha:** 17-oct-2026. **Fuente autoritativa:** consultar siempre el HEAD actual de GitHub; los SHA y contadores en este documento son una fotografía, no sustituyen auditoría concurrente.

## Extensiones implementadas, no tareas pendientes

El **PR #41** (https://github.com/ChicoDotNet/Katas/pull/41) fue fusionado a dev en el commit `6154ef71311bc9f8631c80d4c581469434e78ad9`. Para ese SHA GitHub Actions reportó **17/17 workflows success**, incluyendo los siete workflows de extensiones políglotas. Son verificaciones **aditivas**: **no sustituyen el lenguaje principal** y **no incrementan published_katas**.

| KATA-ID | Producción conservada | Ampliación incorporada | Técnica distintiva |
|---|---|---|---|
| 000009 Bowling | C11 | Julia | 600 partidas completas, contratos de 10 marcos y puntuación C |
| 000003 Game of Life | Fortran | Mojo 1.1 + Pixi | Kernel de celdas empaquetadas, 678 tableros frente a matriz Fortran |
| 000035 Knapsack | Fortran | Julia | Meet-in-the-middle frente a DP Fortran en 502 escenarios |
| 000037 Reactive Cells | JavaScript | Haskell | Evaluación pura de instantáneas de DAG frente a callbacks JS |
| 000039 SGF Parsing | Perl | OCaml | Árbol tipado esperado generado antes de serializar SGF |
| 000044 Dominoes | Go | SWI-Prolog | Paridad de grados y conectividad Euler independientes |
| 000047 VLQ | PHP | Ada + Rust | Rangos u32, errores de representaciones no canónicas, validación cruzada |
| 000048 Connect Hex | C++20 | SWI-Prolog | Recorrido relacional DFS complementario a BFS/DSU |
| 000052 Zipper | TypeScript | R | Editor de árbol por ruta directa y copy-on-modify, 220 historiales |

**Bowling:** la sugerencia original de *contratos de marcos* se refería especialmente a Ada por subtipos/rangos e invariantes fuertes. Julia **sí** puede probar contratos matemáticos de marcos y puntuaciones, y eso es lo implementado. No atribuir capacidades de contratos tipados Ada a Julia.

**Zipper:** R es un buen oráculo independiente por listas recursivas y copy-on-modify. No es necesariamente más adecuado que Haskell/OCaml como lenguaje de implementación principal de un zipper con ADT y tipos; dejar TypeScript como principal mientras no exista comparación con ventaja demostrada.

## Mejoras candidatas para las diez katas con reservas

Todas son **propuestas futuras**, no implementaciones realizadas. No forzar un nuevo lenguaje solo para romper monocultivo Python; comparar el poder detector, independencia algorítmica, derechos y viabilidad. Para cualquier cambio: conservar KATA-ID, evidencia previa en Git, pruebas reales, CI exact-head, PR y cero nuevas katas publicadas.

| KATA-ID | Riesgo exacto | Cambio técnico propuesto | Método para demostrar mejora |
|---|---|---|---|
| **000001 Ugly Trivia** | El juego «legacy» y el refactor son originales; ambos comparten contrato inventado, NO caracterizan el upstream GPL | Tests de *characterization/Golden Master* centrados en transcripciones, metamórficos por guion, intercalaciones de jugadores, eventos y diferencias legacy/refactor | Inyectar mutantes de eventos y orden de turnos; tests Java, posible FSM independiente si aporta valor. Nunca afirmar que refactoriza código GPL ajeno |
| **000002 Banking** | Oráculo cubre ledger/saldos, no errores inyectados, dependencias ni atomicidad | Tests nativos PHP de falla de clock/ledger/renderer, overflow, consistencia de estado y no mutación parcial | Fault injection + API/statement invariants; para un segundo oráculo considerar SQL DECIMAL o COBOL solo si realmente aporta independencia contable |
| **000005 Mars Rover** | Go y Python comparten convenciones de coordenadas, giro y toro | Propiedades de 4 rotaciones, inversas, composición de rutas, traslación en el toro, seguridad de obstáculos y casos de parada parcial | Generador metamórfico geométrico y mutantes de direcciones, sin cambiar el contrato toroidal por polar |
| **000006 Unusual Spending** | Agregado de categorías validado; calendario/servicio/correo solo pocos casos Ruby | Propiedades por desplazamiento mensual incluyendo diciembre→enero, fronteras exactas 50%, cero anterior, múltiples categorías, spies de envío | Ruby Minitest + reloj simulado, fault injection; SQL/COBOL solo si confirma valor en transacciones exactas |
| **000007 Tell Don't Ask** | Referencia Python codifica la misma política de estados que la implementación C++ | Invariantes terminales y transiciones permitidas, rechazo sin mutación, preservación de subtotales y límites monetarios | Property/model-based C++ + pruebas de overflow; posible FSM algebraica en otro lenguaje para reducir fallos compartidos |
| **000008 Race Car Leaderboard** | Algoritmo de puntos/orden es similar en Swift y Python; principalmente temporadas válidas | Invariancia al orden de carreras, aditividad de totales, solo autos autónomos, pilotos repetidos, empates y nombres malformados | Swift XCTest/assertions + metamórficos sin duplicar clasificador por otra sintaxis |
| **000011 Gilded Rose** | 1,445 casos de transición diaria, no secuencias largas | Trayectorias aleatorias de 30–365 días, saturación 0/50, expiración y pases, Sulfuras 80, inmutabilidad | Generador de historial sobre Kotlin, chequeos matemáticos por tipo sin limitarse a modelo que replica el if de Kotlin |
| **000019 Parallel Change** | Contenido del carrito != compatibilidad de cliente Java, inmutabilidad de snapshots y migración real | Compilar clientes antiguos contra API actual y ejecutar; pruebas de defensive copy, deprecation, sustitución y fallo atómico | Java compile-time/backward API contract más mutaciones; no basta oráculo Python sobre listas |
| **000033 Forth** | Python tokens expandidos y bytecode TS comparten supuestos sobre definiciones/redefiniciones | Metamórficos de expansión/alias, redefiniciones encadenadas, shadowing, errores de pila, truncado, overflow | Ejecución directa y compilada con propiedades de equivalencia y generación AST programa-válido/ inválido |
| **000046 Word Search** | Ambos enumeran las mismas 8 direcciones y prioridad de desempate | Tableros con palabras insertadas y unicidad verificada, rotaciones/reflexiones con coordenadas transformadas, empates múltiples adjudicados explícitamente | Transformaciones geométricas que comprueben orientación y desempate sin confiar en posición insertada si otra coincidencia existe |

### Priorización operativa (sugerida)

1. **000005 / 000008 / 000046:** riesgo de verificación por algoritmo demasiado parecido; agregar modelos metamórficos.
2. **000011:** probar secuencias temporales de varios días (bajo coste y gran poder detector).
3. **000001 / 000002 / 000006 / 000007 / 000019 / 000033:** reforzar el aspecto del contrato indicado sin forzar lenguaje nuevo. Resolver en pequeños PRs de pruebas, no bloqueando las nuevas katas hardest-first.

**000045 Two Bucket:** su validador de etiquetas de acciones ya se corrigió e integró en el **PR #40**; no repetirlo como pendiente.

## Métricas y protocolo del siguiente hilo

- En la verificación inicial de este documento: **26/90 publicadas en dev**, **cuatro green**, **61 candidatas acumuladas**, **Ninja v0.1.29**, **14 lenguajes principales** publicados. `main` tiene 20 katas en su release estable; el siguiente hito de promoción obligatoria es **36 publicadas**.
- Las nueve ampliaciones añaden **ocho lenguajes auxiliares distintos** (Julia, Mojo, Haskell, OCaml, Prolog, Ada, Rust, R), sin incrementar el conteo de lenguajes de implementación principal; distinguir siempre los indicadores.
- Revisar primero los PRs/CI actuales, ya que otro agente puede haber publicado las cuatro green mientras se abre el hilo.
- Seguir pilot hardest-first 90/0.16%, catálogo acumulativo con fingerprints y auditoría de licencias, 1–9 katas por iteración, desarrollo local **estrictamente secuencial**, CI paralela sin esperar entre katas, oráculos con técnicas/lenguajes por afinidad, RED/GREEN realmente ejecutados, Ninja versionado y publicación únicamente tras CI exact-head verde y merge.
- Mantener **aspiración 53 lenguajes** sin cuotas ni repertorio artificial; una kata ya publicada puede cambiar de lenguaje bajo la misma ID, recertificada y sin sumar otra publicación.
- No afirmar mejoras causales de Ninja hasta holdout independiente y control de tiempos/retrabajos/dificultad.
