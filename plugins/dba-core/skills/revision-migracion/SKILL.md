---
name: revision-migracion
description: Checklist del equipo DBA para revisar migraciones de esquema (ficheros DDL/DML, Flyway, Liquibase, Alembic, migraciones de Rails o Django). Úsala cuando haya que revisar, aprobar o escribir una migración, o cuando alguien pregunte si un cambio de esquema es seguro para producción.
allowed-tools: Read, Grep, Glob
---

# Revisión de migraciones

Revisa cada fichero de migración contra el checklist. Para cada punto, marca
✅ OK, ⚠️ riesgo o ❌ bloqueante, con la línea concreta del fichero.

## Checklist

### A. Bloqueos y disponibilidad
- [ ] ¿Alguna sentencia toma un bloqueo exclusivo largo sobre una tabla grande?
      (`ALTER TABLE ... ADD COLUMN ... DEFAULT` volátil, cambio de tipo, `ADD CONSTRAINT`
      sin `NOT VALID`, `CREATE INDEX` sin `CONCURRENTLY`/`ONLINE`).
- [ ] ¿Se define `lock_timeout` / `statement_timeout` (o equivalente) al inicio?
- [ ] ¿Las operaciones largas están separadas de las rápidas en migraciones distintas?
- [ ] `CREATE INDEX CONCURRENTLY` en PostgreSQL **no puede ir dentro de una transacción**:
      comprueba que la herramienta de migraciones no la envuelve en una.

### B. Compatibilidad hacia atrás (expand / contract)
- [ ] ¿La versión actual de la aplicación sigue funcionando tras aplicar la migración?
- [ ] Renombrar o eliminar columnas/tablas: ¿se hace en dos despliegues (expand → contract)?
- [ ] `NOT NULL` sobre columna existente: ¿hay backfill previo y constraint `NOT VALID` + `VALIDATE`?

### C. Datos
- [ ] DML masivo (`UPDATE`/`DELETE` de muchas filas): ¿va por lotes y con `WHERE` explícito?
- [ ] ¿Hay estimación del número de filas afectadas?
- [ ] ¿El backfill es idempotente (se puede relanzar)?

### D. Rollback
- [ ] ¿Existe migración de vuelta atrás o un procedimiento documentado?
- [ ] Si el cambio es irreversible (DROP, pérdida de precisión), ¿está marcado y hay backup verificado?

### E. Convenciones del equipo
- [ ] Nombres según las convenciones del proyecto (ver CLAUDE.md del repositorio o la skill
      de convenciones del proyecto si existe).
- [ ] Índices y constraints con nombre explícito (nunca autogenerado).
- [ ] Claves foráneas con índice en la columna referenciante.

## Salida

Usa la plantilla de [plantillas/informe-revision.md](plantillas/informe-revision.md).
Termina con un veredicto único: **APROBADA**, **APROBADA CON CAMBIOS** o **RECHAZADA**.
Si hay al menos un ❌, el veredicto no puede ser APROBADA.
