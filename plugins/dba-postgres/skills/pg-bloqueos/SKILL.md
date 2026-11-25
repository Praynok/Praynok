---
name: pg-bloqueos
description: Investigación de bloqueos en PostgreSQL (sesiones esperando locks, cadenas de bloqueo, deadlocks, "idle in transaction" que bloquea). Úsala cuando haya consultas colgadas, esperas de tipo Lock o timeouts por bloqueo en PostgreSQL.
allowed-tools: Read, Bash(psql:*)
---

# Investigación de bloqueos en PostgreSQL

1. Ejecuta [sql/arbol_bloqueos.sql](sql/arbol_bloqueos.sql) para ver quién bloquea a quién.
2. Identifica la **raíz**: la sesión bloqueante que no está, a su vez, bloqueada por otra.
3. Ejecuta [sql/bloqueos_por_relacion.sql](sql/bloqueos_por_relacion.sql) para ver
   qué tablas y modos de bloqueo están implicados.
4. Clasifica la raíz:
   - `idle in transaction` → la aplicación abrió transacción y no la cerró
     (recomendar `idle_in_transaction_session_timeout`).
   - DDL esperando (`AccessExclusiveLock`) → migración sin `lock_timeout` que encola a todos detrás.
   - Transacción larga legítima (batch) → coordinar con el responsable.

## Informe

```
Raíz: pid <n>, usuario, aplicación, estado, duración
Sesiones afectadas: <n> (esperando hasta <t>)
Tablas: ...
Causa probable: ...
Acción propuesta: (p. ej. "SELECT pg_cancel_backend(<pid>)" o "pg_terminate_backend")
  → requiere confirmación del DBA de guardia; NO ejecutar.
```

Recuerda: `pg_cancel_backend` cancela la consulta; `pg_terminate_backend` cierra la sesión y
hace rollback de toda la transacción. Explica la diferencia en el informe.
