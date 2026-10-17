# Arquitectura: catálogo → prueba → código → evidencia → Ninja

## Fronteras

- Katas es dueño del catálogo, estado, mediciones, soluciones, tests, revisiones del skill y documentación.
- Genkidama es **referencia técnica**, no dependencia de runtime: inspeccionar su learn/_meta/catalog.yml, eng/ci/registry.json, run-family, adapters y .github/workflows/polyglot.yml. Validar toolchains y licencias antes de reutilizar.
- El agente autónomo es un trabajador **aún por conectar**. El workflow horario inicial solo valida y publica un plan JSON auditable, con permisos contents:read. No inventar trabajo generado.

## Datos

- catalog/experiment.json: denominador congelado, estrategia, umbrales, rúbrica.
- catalog/sources.json: fuentes y restricciones.
- catalog/candidates.json: identificador, fingerprint, derechos, dificultad, estado, lenguaje y rutas de evidencia.
- catalog/holdouts.json: evaluaciones pareadas independientes, **no** los enunciados reservados.
- skills/ninja-language-agnostic-developer.md: skill canónico y procedimientos de promoción de conocimiento.

## Flujo lógico

~~~mermaid
flowchart TD
  Schedule[Horario 08:17-17:17 MX] --> Validate[CI y catálogo]
  Validate --> Plan[Propuesta siguiente y artefacto JSON]
  Plan --> Agent{¿Agente aislado conectado?}
  Agent -->|No| Report[Reporte sin cambios]
  Agent -->|Sí| Audit[Auditar fuente/licencia]
  Audit --> Language[Seleccionar lenguaje]
  Language --> Red[Crear pruebas y capturar RED]
  Red --> Green[Implementar, GREEN y refactor]
  Green --> Verify[CI multilenguaje + oráculo independiente]
  Verify --> Ninja[Evaluar lección Ninja]
  Ninja --> PR[PR kata/* a dev]
  PR --> Publish[Publicar solo con evidencia]
~~~

## Activación y seguridad

El cron de GitHub solo funciona desde la rama **default main**, no desde una feature ni dev. Por tanto, este PR no programa ejecuciones hasta promover la configuración a main. GitHub puede retrasar/perder runs; la integración del agente deberá usar checkpoints persistentes e idempotencia. Nunca ejecutar código desconocido en runners self-hosted privilegiados con credenciales. Configurar permisos temporales externos antes de permitir que un agente escriba PRs.

## Primeras tareas de implementación autónoma pendiente

1. Integrar agente externo seguro (selección, pruebas, implementación, PR y reportes).
2. Aislar ejecutores por familia de lenguajes con toolchains reproducibles basados en Genkidama.
3. Persistir exclusión mutua y recuperación de runs omitidos.
4. Añadir oráculos independientes, medición de tokens, tiempos y complejidad.
5. Crear PRs de katas completos y un dashboard longitudinal.
