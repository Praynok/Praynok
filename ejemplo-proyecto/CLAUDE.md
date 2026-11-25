# Proyecto: facturación (base de datos `billing`)

## Contexto
- Motor: PostgreSQL 16 (primario + 2 réplicas). OLTP, ~2.000 TPS en hora punta.
- Migraciones: Flyway, en `migrations/` con formato `V<yyyymmddHHMM>__<descripcion>.sql`.
- Tablas grandes (> 50 GB): `invoices`, `invoice_lines`, `payments`. Cualquier DDL sobre ellas
  requiere revisión del agente `revisor-migraciones` y solicitud de cambio.

## Conexión
- Usa SIEMPRE `psql "$PG_RO_URL"` (rol `claude_ro`, solo lectura, `default_transaction_read_only=on`).
- Entornos permitidos para Claude: `dev` y `staging`. Producción: solo a través de réplicas de
  lectura y solo para consultas de catálogo/estadísticas.
- Nunca leas `.env` ni ficheros `.pgpass`.

## Forma de trabajar del equipo
- Para revisar migraciones: delega en el agente `revisor-migraciones`.
- Para incidencias de rendimiento: delega en `analista-rendimiento` o `guardia-postgres`.
- Para cambios en producción: genera la RFC con `/dba-core:solicitud-cambio-produccion`.
- Convenciones de nombres de este proyecto: skill `convenciones-esquema`.

## Modo líder (un modelo por rol)
Tú eres el líder y respondes de la calidad final. Delega así:
- Leer o buscar en el repo → `explorador` (Haiku).
- Escribir o modificar ficheros → `implementador` (Sonnet).
- Problemas difíciles o de alto riesgo (deadlocks, particionado, HA, migraciones en tablas
  grandes, permisos) → `especialista` (Fable). Es el más caro: úsalo solo en esos casos.
- Revisar migraciones → `revisor-migraciones`.
Intervén tú solo si un subagente se atasca, y revisa siempre su resultado antes de darlo por bueno.

## Estilo
- Respuestas en español. SQL en mayúsculas para palabras clave.
- Cada recomendación debe incluir cómo revertirla.
