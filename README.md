# Katas — Ninja Language-Agnostic Developer

Laboratorio público de katas multilenguaje, pruebas ejecutables y aprendizaje acumulativo. El producto principal es el skill vivo [Ninja](skills/ninja-language-agnostic-developer.md); cada solución es evidencia, no solo una respuesta.

**Estado verificado: 8/90 publicadas en `dev`, catálogo de 31 candidatas del primer barrido de Kata-Log y Ninja v0.1.7.** Cuatro nuevas katas (Go, Ruby, C++20 y Swift) se desarrollaron secuencialmente mientras CI corría en paralelo; se verificaron posteriormente antes del merge. Ver [política de superposición de CI](docs/pipeline-v2.md).

## Programa registrado

- **Censo de planeación:** 55,659 entradas preliminares (aún sin deduplicación o auditoría integral de permisos).
- **Piloto 0.16%:** `ceil(55,659 × 0.0016) = 90` katas publicadas y verificadas.
- **Estrategia inicial:** seleccionar entre candidatas elegibles las más difíciles primero (hardest-first), sin duplicados. Documentar complejidad, valor y evidencia.
- **Punto de decisión:** medir rendimiento en problemas inéditos y tiempo de resolución comparable. Si ambos mejoran, continuar hardest-first hasta 0.8%; de lo contrario, seleccionar por diversidad y ganancia marginal. Si los datos faltan, detener la expansión y revisar.
- **Horizontes:** 0.8%, 4% y 20% condicionados a resultados. La extrapolación de Pareto es hipótesis, no demostración.
- **Cadencia:** lunes a viernes, 08:17–17:17, `America/Mexico_City`, diez oportunidades por día. La ejecución no implica una kata terminada.

## Comandos

~~~sh
python3 -m unittest discover -s tests -v
python3 tools/kata_lab.py validate
python3 tools/kata_lab.py next
python3 tools/kata_lab.py report
python3 tools/kata_lab.py gate
~~~

`next` únicamente construye un plan reproducible: **no ejecuta una IA ni escribe soluciones por sí mismo**. El workflow horario es inicialmente un planificador de solo lectura. Para resolver y crear PRs automáticamente debe conectarse un agente aislado con permisos delimitados y validarlo en un piloto.

## Estados y pruebas

`discovered → eligible → selected → red → green → verified → published`. La publicación requiere licencia específica verificada, vínculo a la fuente, lenguaje justificado, pruebas independientes, CI y una conclusión documentada sobre Ninja (incluso si no cambia).

- [Protocolo del experimento](docs/experiment.md)
- [Arquitectura y activación](docs/architecture.md)
- [Política de procedencia](docs/source-policy.md)
- [Contrato para agentes](AGENTS.md)
- [Genkidama Learn](https://github.com/ChicoDotNet/Genkidama/tree/dev/learn) y [Genkidama Polyglot CI](https://github.com/ChicoDotNet/Genkidama/blob/dev/.github/workflows/polyglot.yml)

## Integración

`main` estable, `dev` integración, `feature/*` infraestructura y `kata/*` katas unitarias mediante PRs. Una variante en otro lenguaje no es una kata canónica diferente.
