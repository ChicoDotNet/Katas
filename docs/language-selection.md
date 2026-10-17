# Selección de lenguaje por afinidad, no por CI

## Regla fundamental

**Primero problema, luego lenguaje, después compilador y CI.** La existencia de un workflow previo en Katas NO puntúa a favor de un lenguaje. La repetición de Java, Go, Python, PHP o TypeScript por comodidad puede sesgar lo que aprende Ninja. **Aspiramos a explorar los 53 lenguajes del catálogo Genkidama**, cada uno con al menos una kata que revele su interés específico, pero sin cuotas ni distribución uniforme.

## Aspiración 53/53 sin cuotas

Explorar los **53 lenguajes** es un objetivo explícito del experimento. Investigar activamente katas que sean especialmente interesantes en lenguajes aún no usados, sin imponer un calendario de lenguajes ni sacrificar hardest-first o la calidad. Si dos alternativas son comparables técnicamente, un lenguaje no explorado puede ganar el desempate. Si una opción tiene afinidad claramente superior, puede repetirse todas las veces que aporte valor.

Una distribución como **49 lenguajes con una kata cada uno y otras 41 katas concentradas en un único lenguaje de altísimo interés** es preferible a un reparto uniforme artificial. Es un ejemplo, no una cuota, y la repetición no tiene límite.

Medir separadamente cantidad de katas publicadas, lenguajes distintos de implementación principal realmente publicados, lenguajes efectivamente probados con RED/GREEN, y hallazgos distintivos. Un lenguaje mencionado en una propuesta o instalado en CI no cuenta como utilizado.

## Reelección y reemplazo de una kata ya validada

Una implementación incluso verificada o publicada **puede reemplazarse por otra en un lenguaje más adecuado**, siempre que una nueva evaluación demuestre valor técnico superior, no solo interés en subir el contador de lenguajes.

1. Auditar la especificación existente y comparar al menos tres opciones; documentar el aprendizaje distintivo del nuevo lenguaje y los costes de cambiar.
2. Conservar la implementación anterior publicada y operativa mientras se prepara una rama de migración. Reutilizar **la misma KATA-ID** y guardar en el reporte de migración el lenguaje anterior, el nuevo, la justificación, el contrato preservado, los SHAs y el enlace al PR. El código anterior debe quedar recuperable mediante Git.
3. Escribir y ejecutar nuevos RED/GREEN con el compilador elegido, suite del contrato, oráculo independiente y, cuando proceda, pruebas diferenciales cruzadas con la implementación anterior. CI verde sobre el commit exacto, revisión y squash merge a dev son requisitos nuevos: no reutilizar el GREEN del lenguaje reemplazado.
4. Solo tras esa certificación cambiar la implementación principal, sus metadatos y la observación Ninja pertinente. Si la nueva falla, se conserva la publicada. Si main ya contiene la versión antigua, llevar la nueva mediante release controlado, sin reescritura de historia.
5. **El reemplazo nunca crea una nueva kata publicada:** published_katas permanece igual; tampoco mueve hitos de main cada 18 katas. La cobertura de lenguajes principales puede subir o bajar, según se mantenga o pierda la última kata del lenguaje antiguo. Conservar además el historial de exploraciones anteriores sin contarlas dos veces.

Reevaluar el lenguaje no implica descartar evidencia de una solución original: implica preservar su historia y exigir **certificación completa e independiente** para la sustituta.
## Protocolo obligatorio antes de comenzar código

1. Caracterizar el problema: dominio, invariantes, representación, fallos, complejidad y qué merece probar.
2. Comparar **al menos tres lenguajes viables del universo Genkidama** por ajuste conceptual; incluir alternativas de paradigmas distintos cuando resulte apropiado, no tres clones del preferido.
3. Documentar qué hace el lenguaje ganador particularmente idiomático o revelador. Añadir un contrafactual: qué se perdería de resolver siempre en C#, Java, Go o Python.
4. Solo entonces inspeccionar Genkidama Learn, eng/ci/registry.json, run-family y .github/workflows/polyglot.yml para obtener toolchain y adaptar GitHub Actions a Katas.
5. Exigir RED que falle por conducta, GREEN ejecutado con el compilador auténtico, oráculo independiente, proveniencia, Ninja versionado y CI para el SHA exacto. Si no hay toolchain accesible, reportar impedimento; no marcar GREEN ni sustituir por un lenguaje sencillo sin nueva evaluación.
6. Auditar sesgos al cierre: registrar alternativas consideradas, razones de rechazo y decisiones por CI fácil. Dar seguimiento a las oportunidades de explorar los 53 lenguajes sin volver la diversidad una cuota ni una excusa para bajar calidad.

### Decisión mínima en cada README

| Campo | Respuesta obligatoria |
|---|---|
| Problema e invariantes | Dominio, casos borde, estructura principal |
| Tres candidatos | Qué harían más claro y qué complicarían |
| Ganador | Por qué resulta particularmente interesante en ese lenguaje |
| Contrafactual | Lo que se pierde o se complica usando de nuevo un lenguaje habitual |
| Infraestructura, después | Compilador y CI que se debe preparar, basado en Genkidama |
| Pruebas reales | RED, GREEN y oráculo **efectivamente ejecutados**, con sus comandos |

**La infraestructura disponible no es ventaja semántica.** Seguridad, derechos y capacidad auténtica de ejecutar son condiciones de viabilidad, no puntos para decidir quién encaja mejor.

## Hipótesis de afinidad para explorar, NO asignaciones ni cuotas

| Lenguaje | Aprendizaje distintivo potencial | Candidata para auditar |
|---|---|---|
| **Ada** | Tipos/rangos, contratos, invariantes de sistemas críticos | KATA-000020 Race Car Telemetry si el contrato real es apropiado para sensores y estados |
| **Julia** | Cálculo numérico, arreglos, despacho múltiple y estabilidad de tipos | Buscar una nueva candidata de simulación/optimización; no forzar CRUD ni ranking de cartas |
| **COBOL** | Contabilidad decimal exacta, registros y procesamiento batch | KATA-000058 Ledger (evaluar y auditar su especificación) |
| **Visual Basic .NET** | Modelado empresarial, eventos y objetos tipados sobre .NET | KATA-000013 Clock-in si sus reglas horarias ofrecen un caso interesante |
| **Mojo** | Tipos de valor, kernels de matrices y bucles vectorizados | KATA-000049 Flower Field o un problema de stencil adecuado; medir corrección antes de rendimiento |
| **Prolog** | Restricciones lógicas, relaciones y búsqueda declarativa | KATA-000034 Zebra Puzzle, tras verificar licencia y semántica |

La lista es una cantera de investigación, no una promesa de asignación, disponibilidad de compiladores o aprobación automática de la licencia. Todos los demás lenguajes Genkidama compiten con las mismas reglas, incluidos Pascal, R, OCaml, Haskell, Zig, Nim, Erlang y Scala.

## Estado de referencia revisado en Genkidama el 17 de octubre de 2026

- El catálogo learn/_meta/catalog.yml lista Ada, cobol, julia, vbnet y mojo; Mojo figura como backlog.
- La familia GNU de .github/workflows/polyglot.yml instala gnat, gnucobol3, Pascal y Fortran.
- La familia longtail instala Julia; dotnet utiliza runners Linux/Windows para la familia que incluye VB.NET; Mojo dispone de una familia separada basada en Pixi.
- Son **referencias para adaptar el aprovisionamiento**, no pruebas de que una kata nueva haya pasado CI en Katas. Cada ejecutor y licencia se verifican por ejercicio.

## Antipatrones

- «Go porque ya hay un workflow».
- «JavaScript porque el entorno ya tiene Node».
- «Ada porque toca diversificar», aunque no aporte aprendizaje real.
- «Mojo es correcto por inspección», sin poder ejecutar sus herramientas.
- «CI en Genkidama ya pasó, entonces esta kata también».

El objetivo aspiracional es explorar los **53 lenguajes** mediante katas especialmente interesantes, con calidad demostrada, libertad para repetir y posibilidad de reemplazar retrospectivamente una elección mejorable.
