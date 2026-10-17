# EXP-001: piloto hardest-first del 0.16%

Estado: **experimento en ejecución (8/90 katas publicadas); el protocolo original se conserva más abajo**. Fecha inicial: 2026-10-17. La actualización de estado no cambia los umbrales preregistrados. La publicación de cuatro katas con CI superpuesta se hizo en PR #11; catálogo ampliado de 4 a 31.

## Pregunta

¿Puede un skill externo, vivo y versionado aumentar la transferencia de aprendizaje y reducir el tiempo de resolver problemas nuevos de programación a partir de experiencias con código y pruebas verificadas?

## Universo y objetivos

El censo preliminar contiene 55,659+ entradas heterogéneas. Congelamos **55,659 como denominador de planeación**, no como número probado de katas únicas con permiso de reproducción. Se debe auditar y deduplicar antes de interpretar porcentajes como cobertura mundial.

| Fase | Porcentaje | Umbral (ceil) |
| --- | ---: | ---: |
| Piloto EXP-001 | 0.16% | 90 |
| Foundation | 0.8% | 446 |
| Expansión condicional | 4% | 2,227 |
| Largo plazo | 20% | 11,132 |

Pareto recursivo 0.2³ = 0.8% y 0.8³ = 51.2% sirve solo como hipótesis de concentración del valor. Lo más difícil no tiene por qué ser lo más transferible: registraremos ambas variables.

## Selección

1. Capturar URL, fuente, identidad canónica, permisos y enlaces.
2. Deduplicar por invariantes y contrato, no por lenguaje, título ni URL.
3. Verificar licencia de cada recurso antes de reproducirlo.
4. Puntuar: transferencia 20, profundidad 20, calidad del oráculo 15, TDD 15, novedad 10, pedagogía 10, portabilidad 5, mantenimiento 5.
5. **Piloto:** ordenar candidatas elegibles por dificultad auditada (0–5) descendente, score descendente, identificador estable. Dificultades de candidatos recién descubiertos son provisionales.
6. Mantener trazabilidad de temas y lenguajes; no permitir duplicados conceptuales para llenar la cuota.
7. Solo contar published con CI, pruebas independientes, evidencia de estados y revisión Ninja.

## Cadencia y metrología

Diez ventanas horarias de lunes a viernes 08:17–17:17 zona America/Mexico_City. Continuar trabajos inconclusos antes de iniciar otros. Cada ventana puede terminar cero o más katas. Registrar duración activa, tiempo de setup de toolchain, versión del skill, modelo/herramientas, dificultad, familia, resultado de pruebas, intentos, tokens/costo si se dispone, lenguaje y intervención humana. Valores ausentes permanecen UNKNOWN.

## Regla de decisión preregistrada y exploratoria

Al llegar a 90 published, comparar **mismo modelo base, herramientas, presupuesto y límites** con el skill congelado v1 frente al Ninja actualizado sobre **30 ejercicios nuevos y emparejados**, reservados del entrenamiento. Exigir al menos 10 ejercicios en los que ambas versiones pasen para comparar velocidad.

- Transferencia: ventaja absoluta de éxito Ninja de **al menos 10 puntos porcentuales**.
- Velocidad: mediana de `tiempo_ninja / tiempo_baseline <= 0.90` entre pares aprobados por ambos.
- Calidad: oráculo independiente para cada éxito. Regresiones importantes requieren revisión humana.

Si ambas metas se cumplen, recomendar continuar hardest-first hasta 0.8%. Si una falla, pasar a selección por cobertura/diversidad. Si falta evidencia, estado **review_required** y no lanzar otra kata. El script calcula una recomendación, no prueba causalidad ni reemplaza auditoría humana. Reportar sesgo de muestra, intervalos de confianza y composición de la muestra antes de comunicar conclusiones.

Los problemas de evaluación no deben filtrarse al skill ni reutilizarse en posteriores pruebas. Fijar nuevas reglas antes de expandir.

## Riesgos

La dificultad desplaza tiempos; comparar pares emparejados y no solo promedios de días. La IA puede entrenarse en las mismas katas del benchmark, sobreajustar un lenguaje y generar pruebas que confirmen un error compartido. El tamaño del skill puede degradar rendimiento. Se debe registrar y permitir revertir reglas erróneas.
