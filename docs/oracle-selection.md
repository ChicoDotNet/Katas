# Elegir el mejor lenguaje para probar cada kata

## Tres decisiones independientes

**Queremos experimentar con los 53 lenguajes también como herramientas para probar, no solo para implementar.** El problema y la capacidad de detectar sus fallos determinan las decisiones:

1. **Implementación:** el lenguaje que hace especialmente interesante la solución de la kata.
2. **Pruebas de aceptación:** preferir frameworks o pruebas idiomáticas del propio lenguaje cuando ayuden a expresar contratos, límites, excepciones, concurrencia y tipos.
3. **Oráculo diferencial, formal o metamórfico:** elegir un modelo de referencia y el lenguaje que más clara, independiente y rigurosamente lo exprese. El lenguaje del oráculo puede ser el mismo que el principal, o uno diferente, incluyendo Ada, COBOL, Julia, Haskell, Prolog, R, VB.NET, Fortran, Mojo, Python, SQL u otros cuando sean pertinentes.

**Independencia no significa diferente extensión de archivo.** Dos traducciones del mismo algoritmo pueden compartir un error. Una búsqueda exhaustiva y programación dinámica en el MISMO lenguaje pueden ser más independientes que dos traducciones de programación dinámica en lenguajes distintos.

## Procedimiento obligatorio por kata

1. Identificar fallos que deben detectarse: rangos, overflow, conectividad, decimales, formatos, transacciones, identidad, orden, límites, tolerancias, carreras o mutación.
2. Comparar **al menos dos estrategias de verificación** por su poder de detectar fallos y su independencia estructural. Ejemplos: fuerza bruta vs heurística, BFS vs union-find, reconstrucción AST generada primero vs parser, solver de restricciones vs simulación, propiedades metamórficas vs referencia.
3. Para cada estrategia viable, considerar lenguajes por afinidad, expresividad, rigurosidad y reproducibilidad. Elegir el lenguaje de pruebas y el de oráculo **después** de la estrategia. Python no tiene preferencia automática, aunque puede ganar con fundamentos técnicos.
4. Ejecutar RED que compile y falle por conducta, GREEN auténtico y el oráculo con sus herramientas reales, en un entorno seguro. Si la referencia necesaria no puede ejecutarse, no declarar development_complete.
5. Registrar riesgo de error compartido: misma librería, lógica copiada, convenciones de índices, diferencia Unicode, tolerancias, rangos, supuestos inválidos del generador o falta de independencia del dataset.
6. Añadir los jobs pertinentes de CI. Ningún oráculo se considera ejecutado solamente por estar escrito o por depender de un workflow verde ajeno.
7. Al cerrar el bloque, reportar lenguajes de implementación, de tests y de oráculos por separado, así como **técnicas** de verificación. No imponer cuotas de lenguajes.

### Minisección obligatoria en cada README

| Función | Técnica, lenguaje y evidencia |
|---|---|
| Implementación | Afinidad semántica y algoritmo |
| RED/GREEN | Framework/herramienta y contratos nativos |
| Oráculo elegido | Modelo independiente y lenguaje justificado |
| Estrategia alternativa | Otra técnica considerada y por qué se descartó/complementó |
| Riesgo de error compartido | Supuestos y dependencias comunes |
| Comandos/CI | Versión de toolchain, RED, GREEN, oráculo, workflow exacto |

## Ejemplos de posibles emparejamientos; nunca asignaciones obligatorias

| Dominio | Ejemplo de solución | Técnicas/herramientas que merecen evaluar |
|---|---|---|
| Contabilidad y moneda decimal | COBOL | Casos batch COBOL, comprobación decimal exacta con SQL o VB.NET |
| Matrices, PDE y simulación | Julia | Julia Test, invariantes numéricas y referencia de otro método en Fortran o R |
| Sistemas con contratos y rangos | Ada | AUnit, pruebas de excepciones de rangos y modelo funcional independiente |
| Restricciones y relaciones | Prolog | Consultas declarativas, SAT o búsqueda exhaustiva complementaria |
| Eventos y dominios empresariales | VB.NET | Pruebas VB.NET y simulación independiente de eventos |
| Kernels y memoria | Mojo | Pruebas nativas de valor, límites y rendimiento reproducible, referencia matemática distinta |
| Parsing | lenguaje apropiado | Generar AST primero y serializar; propiedades de gramática y rechazo |
| Estructuras persistentes | Haskell, OCaml, Rust, etc. | Referencia de edición directa y propiedades de no mutación |

Las técnicas se eligen por evidencia; no usar Prolog para contabilidad ni Julia para todo el cálculo por cuota. Probar un lenguaje con sí mismo es válido y a veces ideal, siempre que la independencia de prueba esté justificada.

## Auditoría basal: 2026-10-17

Se cruzaron los 26 registros publicados de catalog/candidates.json en el commit d949743b76fe60af295af1e39cb666e8e7824002 con archivos Git de pruebas. **26/26 katas publicadas tienen oráculo diferencial en Python**: 25 archivos tests/differential.py y uno tests/test_differential.py. Esto es una dependencia de la capa diferencial en el runtime Python. **No significa** que todas las pruebas sean Python: varias soluciones ya tienen RED/GREEN y suites nativas en C, C++, Fortran, Erlang, Swift, etc. Tampoco hemos comprobado que los 26 modelos Python sean causalmente independientes solo por su extensión.

Corregir de manera evolutiva: en katas NUEVAS hacer elección explícita de oráculo; en katas existentes revisar cuando se descubre una debilidad, una mejor técnica, o una oportunidad técnica relevante. No reescribir los 26 solamente para presentar diversidad.

La introducción o reemplazo de un oráculo ya publicado es trabajo de mejora de **la misma KATA-ID**, con PR, nuevos tests y CI exact-head. No se cuenta como nueva kata ni mueve los hitos de release. Guardar la versión anterior en historial Git y documentar el cambio.

**Objetivo final:** evidencia de mayor calidad, menor monocultivo de infraestructura y aprendizaje real de lenguajes también desde el lado de la verificación.
