# Seguimiento de la auditoría de oráculos — reservas, migraciones y cadencia

**Fecha:** 17 de octubre de 2026. **Base de la auditoría anterior:** [oracles-2026-10-17.md](oracles-2026-10-17.md). Evaluación de código, README y pruebas de cada kata; la clasificación no es una estimación estadística de confianza ni un resultado de mutation testing general. La revisión no convierte una dificultad autocalificada en un ranking externo hardest-first.

## Las diez reservas detalladas

| KATA-ID | Reserva exacta | Tipo de problema | Acción recomendada |
|---|---|---|---|
| 000001 Ugly Trivia | El juego legado y el refactor son construcciones originales, no la implementación GPL enlazada. Python modela **nuestras** reglas y no prueba fidelidad al starter original. | Alcance/procedencia y modelo normativo compartido | Pruebas metamórficas de transcripción, caracterización del legado propio; no copiar GPL ni afirmar la equivalencia original. |
| 000002 Banking | El oráculo diferencial recorre saldos correctos en límites ordinarios; errores de puertos, overflow, fallos inyectados y atomicidad no forman parte de esas historias, aunque PHP prueba varios límites. | Cobertura entre capas | Mejorar pruebas nativas para fallos de clock/ledger/formatter y comportamiento de overflow; mantener el modelo de libro contable. |
| 000005 Mars Rover | El modelo Python y Go usan las mismas direcciones, coordenadas y módulo toroidal; una interpretación equivocada podría repetirse. La geometría polar está fuera del contrato local. | Fallo común semántico | Propiedades de cuatro rotaciones, inversas, composición de movimientos, seguridad frente a obstáculos y otras convenciones comprobadas. |
| 000006 Unusual Spending | El diferencial Ruby/Python agrega importes por categoría, pero no verifica límites de meses, interfaz de envío ni ausencia de correos; éstos se prueban en Ruby con pocos ejemplos. | Contrato de servicio no cubierto por diferencial | Aumentar pruebas de calendario, inyección de reloj/origen y spy del mailer, especialmente cambios de año y no enviar ante umbral no alcanzado. |
| 000007 Tell Don't Ask | Python reescribe la misma tabla de estados de negocio que C++ aun con estructuras distintas. Error de política podría compartirse; límites aritméticos son más reducidos. | Política común y aritmética | Invariantes de estados terminales, no mutación ante comando inválido, cálculo monetario y casos cerca de límites. |
| 000008 Race Car Leaderboard | Ambos oráculos agregan puntos por posición y ordenan. Los 300 escenarios se concentran en temporadas válidas; Swift tiene otros tests nativos. | Algoritmo similar y casos negativos | Propiedades de suma de temporadas, invariancia a permutar carreras, desempates estables, validación de pilotos repetidos/nombres inválidos. |
| 000011 Gilded Rose | Python verifica transición de **un día**, no historias de 30–365 días, agotamiento y saturación progresiva. Las reglas están replicadas en la tabla de referencia. | Propiedades temporales | Añadir escenarios multi-día y límites, idealmente pruebas metamórficas en Kotlin; no hace falta migrar el oráculo. |
| 000019 Parallel Change | La lista Python modela valores y suma, pero no verifica compatibilidad real de clientes Java antiguos, copias defensivas ni atomicidad ante entradas inválidas. | Compatibilidad/contratos API | Ampliar pruebas Java del cliente antiguo y snapshots con mutaciones, invalid bulk updates y deprecations; conservar referencia simple. |
| 000033 Forth | Python expande tokens y TS ejecuta bytecode, una independencia razonable, pero comparten reglas inventadas de redefinición y tipos numéricos seguros. | Semántica común / combinaciones profundas | Propiedades de sustitución/equivalencia de definiciones, shadowing y errores de stack bajo combinaciones profundas. |
| 000046 Word Search | Python recorre las mismas 8 direcciones y la misma prioridad de desempate que Swift; traducción de la especificación muy similar. | Independencia geométrica limitada | Generación constructiva de palabras plantadas; rotación/reflexión metamórfica de tableros con adjudicación de empates para detectar inversión de ejes. |

**Priorización:** 000005, 000008 y 000046 son las mejores candidatas a un segundo mecanismo independiente; 000002, 000006 y 000019 necesitan sobre todo pruebas nativas del contrato. En ningún caso el cambio de lenguaje *por sí solo* corrige la reserva.

## Las 13 «sólidas» tampoco son intocables

La palabra «sólida» califica la **independencia actual del oráculo**, no declara que su lenguaje principal sea óptimo para siempre.

| KATA-ID | Qué funciona | Posible alternativa si demuestra valor superior | Decisión presente |
|---|---|---|---|
| 000003 Game of Life (Fortran) | Conjunto de vecinos frente a matriz numérica | Mojo/Julia para kernels o stencil, manteniendo una referencia dispersa | Conservar; corregir conteo 678 |
| 000004 Gossip (Erlang) | Máscaras concurrentes frente a sets por estación | Prolog, relaciones temporales declarativas como tercera referencia | Conservar |
| 000009 Bowling (C) | Frames completos frente a tiros | Ada para contratos de marcos/rangos; COBOL para procesamiento de hojas | Conservar hasta probar ventaja |
| 000032 Alphametics (Python) | Backtracking con poda frente a permutaciones exhaustivas | **Prolog CLP(FD)** para solver declarativo genuinamente distinto | Candidata de investigación prioritaria; no borrar referencia exhaustiva |
| 000035 Knapsack (Fortran) | DP frente a fuerza bruta exhaustiva | Julia para estudio de formulaciones numéricas | Conservar; no hay mejora demostrada |
| 000037 Reactive Cells (JavaScript) | Propagación del DAG frente a recálculo por snapshot | Haskell para semántica funcional; no equivale necesariamente a callbacks JS | Conservar |
| 000039 SGF (Perl) | AST esperado generado antes del texto | OCaml/Haskell, AST tipado y generadores de propiedades | Investigar como complemento, no sustituir sin mejora |
| 000044 Dominoes (Go) | Ciclo Euler frente a permutación exhaustiva de fichas | Prolog relacional como referencia adicional | Conservar |
| 000047 VLQ (PHP) | Decodificación/bit shifts frente a potencia y división | Ada/Rust para límites estrictos de palabras | Conservar |
| 000048 Connect Hex (C++) | BFS frente a union-find | Prolog para conectividad declarativa independiente | Conservar |
| 000052 Zipper (TypeScript) | Breadcrumb zipper frente a editor directo por ruta | **Haskell u OCaml** con ADTs y persistencia inmutable nativa | **Mejor candidata a prototipo de reemplazo del lenguaje principal** |
| 000054 Satellite (Java) | Reconstrucción frente a árbol original generator-first | Haskell/OCaml para árbol recursivo y tipado | Conservar |
| 000056 Circular Buffer (C) | Índices circulares frente a deque | Ada para rangos/contracts o Rust para ownership | Conservar C por valor pedagógico de invariantes explícitos de memoria |

**Regla de decisión:** prototipar una alternativa cuando ofrece una ventaja conceptual concreta. Reemplazar la **misma KATA-ID** solo si las nuevas pruebas, el oráculo y CI demuestran una solución mejor para los objetivos del ejercicio. No sumar otra kata publicada por migración. No convertir afinidad potencial en prueba de superioridad.

## Hallazgo convertido en prueba concreta: Two Bucket

En 000045 detectamos un defecto comprobable del *harness*: aceptaba una secuencia de estados correcta aunque la secuencia de **acciones declaradas fuese incorrecta**, porque validaba pertenencia al conjunto de sucesores posibles pero no la acción asociada. El endurecimiento añade un verificador de acciones interpretadas por nombre y pruebas que alteran intencionalmente cuatro etiquetas y un estado intermedio. El oráculo de mínima distancia sigue siendo independiente. El pequeño ensayo sintético local pasó: **una ruta válida aceptada y cinco mutantes de testigo rechazados**; la certificación de integración debe producirse en CI exact-head.

## Sobre la velocidad y el número de interacciones

GitHub muestra primer PR de Ninja a las **08:38:14 UTC** (17-oct-2026) y publicación formal de la kata 26 en PR #30 a las **20:22:01 UTC** del mismo día, diferencia de **11 h 43 min 47 s** de reloj, incluidos intervalos sin trabajo activo. Había 26 publicadas, cuatro adicionales GREEN en el PR #31, 14 lenguajes principales en las 26 y 39 PRs creados / 34 fusionados al momento de la auditoría original. Estos PRs **no** miden interacciones de ChatGPT ni tiempo activo de ingeniería.

No se dispone de un contador fiable del número exacto de turnos de usuario del hilo. Si fuese 26–29, el cociente sería **26/29 = 0.897 a 26/26 = 1.000 katas publicadas por interacción**; es condicional, no una medición observada. El progreso combina código, CI solapada, catálogo, branching, licencias, pruebas, experimentación de paradigmas y creación del skill. Es un avance operativo excepcionalmente favorable, pero aún no demuestra aceleración causal del Ninja, calibración hardest-first ni generalización en holdout.

## Recomendación

**GO para siguiente bloque**, sin migración masiva. Fortalecer primero pruebas con defectos verificables, como 000045, y evaluar técnicamente dos prototipos de gran potencial: **Zipper en OCaml/Haskell** como migración conceptual y **Alphametics con Prolog CLP(FD)** como oráculo/solver adicional. No prometer que las alternativas son superiores sin ejecuciones ni imponer diversidad ornamental.
