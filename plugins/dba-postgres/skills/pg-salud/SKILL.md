---
name: pg-salud
description: Chequeo de salud de una instancia PostgreSQL con las consultas estándar del equipo (conexiones, transacciones largas, replicación, vacuum, bloat, caché, wraparound). Úsala cuando pidan revisar la salud de un PostgreSQL, preparar un informe de estado o investigar una degradación en PostgreSQL.
allowed-tools: Read, Bash(psql:*)
---

# Chequeo de salud PostgreSQL

Ejecuta las consultas de la carpeta `sql/` **en este orden**, con el rol de solo lectura
y con `psql -X -A -F '|' --pset footer=off` para que la salida sea compacta.

Todas las consultas son SELECT sobre vistas de catálogo: no modifican nada.

| Orden | Fichero | Qué mide | Umbral de alerta |
|---|---|---|---|
| 1 | [sql/01_conexiones.sql](sql/01_conexiones.sql) | Conexiones por estado frente a `max_connections` | > 80 % o `idle in transaction` > 5 |
| 2 | [sql/02_transacciones_largas.sql](sql/02_transacciones_largas.sql) | Transacciones abiertas > 5 min | Cualquiera |
| 3 | [sql/03_replicacion.sql](sql/03_replicacion.sql) | Lag de réplicas y slots inactivos | Lag > 60 s o slot inactivo reteniendo WAL |
| 4 | [sql/04_vacuum.sql](sql/04_vacuum.sql) | Tuplas muertas y último autovacuum | `n_dead_tup` > 20 % de `n_live_tup` |
| 5 | [sql/05_wraparound.sql](sql/05_wraparound.sql) | Edad de XID por base de datos | > 1.000 millones |
| 6 | [sql/06_cache.sql](sql/06_cache.sql) | Ratio de aciertos de caché | < 99 % en OLTP |

Ejemplo de ejecución (las rutas de `sql/` son relativas a la carpeta de esta skill;
usa la ruta absoluta que Claude ve al cargar la skill):

```bash
psql "$PG_RO_URL" -X -A -F '|' --pset footer=off -f <carpeta-skill>/sql/01_conexiones.sql
```

## Informe

```
# Salud PostgreSQL — <instancia> — <fecha>

| Área | Estado | Valor | Umbral | Nota |
|---|---|---|---|---|
| Conexiones | 🟢/🟡/🔴 | | | |
...

## Acciones recomendadas (priorizadas)
```

Las acciones correctivas (VACUUM manual, eliminar slots, terminar sesiones) se **proponen**,
nunca se ejecutan.
