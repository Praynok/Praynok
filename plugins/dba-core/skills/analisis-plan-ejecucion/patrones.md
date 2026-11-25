# Patrones de planes de ejecución

| Patrón | Cómo se ve | Causa típica | Primera acción |
|---|---|---|---|
| Seq Scan / Full Table Scan sobre tabla grande con filtro selectivo | `Seq Scan` con `Rows Removed by Filter` muy alto | Falta índice o predicado no sargable | Revisar predicado; después índice |
| Predicado no sargable | Función sobre la columna: `WHERE lower(email) = ...`, `WHERE fecha::date = ...` | El índice no se puede usar | Reescribir o índice por expresión |
| Nested Loop con muchas iteraciones | `loops` en miles/millones en el lado interno | Mala estimación de cardinalidad | Estadísticas; luego valorar hash join |
| Sort / Hash que se va a disco | `Sort Method: external merge`, `Batches > 1` | `work_mem` / memory grant insuficiente | Ajustar a nivel de sesión, no de instancia |
| Key Lookup / Heap Fetches altos | `Heap Fetches` alto en Index Only Scan, `Key Lookup` en SQL Server | Índice no cubriente o visibility map desactualizado | Índice con INCLUDE; VACUUM |
| Conversión implícita | `CONVERT_IMPLICIT`, casts en el filtro | Tipos distintos entre parámetro y columna | Corregir el tipo en la aplicación |
| Paginación con OFFSET grande | `Limit` tras leer millones de filas | `OFFSET n` | Paginación por clave (keyset) |
| OR entre columnas distintas | Scan completo pese a tener índices | El optimizador no combina índices | `UNION ALL` o bitmap OR |
| Estimación = 1 fila | `rows=1` en nodos que devuelven miles | Variables de tabla, CTE materializada, estadísticas ausentes | Estadísticas / reescritura |
