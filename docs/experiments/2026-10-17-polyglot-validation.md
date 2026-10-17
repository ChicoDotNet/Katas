# Expansión de nueve katas a verificadores políglotas — 17-oct-2026

**Objetivo:** incorporar nuevos lenguajes **porque el problema resulta interesante en ellos**, sin reemplazar los nueve lenguajes originales, sin cuotas ni duplicar publicaciones. Seleccionar técnicas independientes, test nativo y modelos cruzados por afinidad, no por un workflow ya existente.

| KATA | Principal (sin cambios) | Extensión añadida | Aporta |
|---|---|---|---|
| 000009 Bowling | C | Julia | Contratos semánticos de los diez marcos y 600 partidas |
| 000003 Game of Life | Fortran | Mojo 1.1 | Kernel empaquetado en bits, 678 tableros |
| 000035 Knapsack | Fortran | Julia | Meet-in-the-middle, 502 problemas |
| 000037 Reactive Cells | JavaScript | Haskell | Recomputación pura de 180 DAGs |
| 000039 SGF Parsing | Perl | OCaml | AST tipado generado antes del SGF, 180 árboles |
| 000044 Dominoes | Go | SWI-Prolog | Paridad y conectividad, 454 decisiones |
| 000047 VLQ | PHP | Ada + Rust | Dominios u32, representaciones canónicas, rechazos |
| 000048 Connect Hex | C++20 | SWI-Prolog | Existencia relacional de caminos, 455 tableros |
| 000052 Zipper | TypeScript | R | Edición directa de árbol y copy-on-modify, 220 historiales |

**Importante sobre Bowling:** Ada favorece tipos y rangos formales; Julia aquí comprueba de forma muy útil el contrato matemático de los marcos. Ambos son razonables, pero su enseñanza no es idéntica.

**Importante sobre Zipper:** R no sustituye TypeScript; se usa como *oráculo independiente*. El potencial de Haskell/OCaml como lenguaje principal de una futura migración sigue abierto a evaluación.

**CI y estado:** Los ejecutables fueron añadidos a workflows específicos en el PR de esta expansión. No interpretar la presencia de código, ni los tests verdes de las katas previas, como éxito remoto del nuevo verificador. Para aprobar el lote, cada workflow debe demostrar GREEN en el HEAD exacto, incluida la cadena Rust/Ada y el entorno Mojo/Pixi. El manuscrito de diseño no es un certificado CI.

Las pruebas en Julia, R, Prolog y OCaml se realizan con **modelos independientes**; Haskell usa snapshots puros, Mojo bits empaquetados, Ada y Rust implementaciones del contrato de VLQ. El transporte Node en algunos casos no ejecuta el oráculo: simplemente entrega entradas y compara salidas. Ningún caso incrementa el conteo oficial published.

**Evolución y límites:** Esta ampliación no mide aceleración causal de Ninja, ni demuestra que los lenguajes adicionales sean universalmente superiores. El objetivo es aumentar independencia metodológica, habilidades de toolchain y diversidad significativa de verificación. La publicación mantiene los ID, el código base, los oráculos previos y los criterios de gobernanza.
