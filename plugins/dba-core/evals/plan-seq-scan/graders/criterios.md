---
type: llm
weight: 2
---

Una respuesta correcta:
- Identifica el Seq Scan como nodo crítico y que se descartan ~5 millones de filas.
- Detecta que el predicado `lower(email)` no es sargable.
- Señala el error de cardinalidad (25000 estimadas frente a 3 reales).
- Propone un índice por expresión sobre `lower(email)` creado con `CREATE INDEX CONCURRENTLY`
  e incluye la sentencia de rollback (`DROP INDEX CONCURRENTLY`).
- Sigue el formato con secciones Resumen, Nodo crítico, Hallazgos, Recomendaciones y Verificación.
