# Soluciones de los ejercicios

## Ejercicio 1 — Ejemplo de inventario

| Método | Pieza | Por qué |
|---|---|---|
| "Esta BD es Oracle 19c RAC de 2 nodos" | CLAUDE.md | Hecho siempre necesario en ese proyecto |
| Checklist de migraciones | Skill | Procedimiento usado a veces |
| Consultas de salud semanales | Skill con `sql/` | Biblioteca de consultas probadas |
| Plantilla de RFC | Skill manual | Produce un artefacto con consecuencias |
| "Nunca TRUNCATE en prod" | Hook + rol + permiso deny | Debe cumplirse siempre |
| Revisión de PRs de esquema | Subagente | Rol con herramientas restringidas |
| Acceso a Grafana | MCP | Sistema externo |

## Ejercicio 3

- `psql -h db-prod-01 ...` → coincide con `Bash(psql*prod*)` en **deny**: bloqueado aunque
  `Bash(psql:*)` esté en allow (deny gana).
- `cat .env` → no coincide con un `Read` directo, pero Claude normalmente usará la herramienta
  `Read`, que está denegada. Para cubrir también `cat`, añade `Bash(cat*.env*)` en deny
  o, mejor, no tengas el `.env` con credenciales de BD en el repo.

## Ejercicio 6

Hallazgos esperados del `revisor-migraciones` sobre
`ejemplo-proyecto/migrations/V202611250900__add_status_to_invoices.sql`:

| Sección | Hallazgo | Estado |
|---|---|---|
| A | `CREATE INDEX` sin `CONCURRENTLY` sobre `invoices` (> 50 GB): bloquea escrituras durante toda la creación | ❌ |
| A | Sin `lock_timeout`: el `ALTER TABLE` puede encolar todo el tráfico detrás si hay una transacción larga | ❌ |
| A | `ADD CONSTRAINT ... FOREIGN KEY` sin `NOT VALID` + `VALIDATE CONSTRAINT` posterior: valida toda la tabla con bloqueo | ⚠️ |
| A | `ADD COLUMN ... NOT NULL DEFAULT 'pending'`: en PG 11+ con default constante es solo metadatos (OK), pero conviene confirmarlo y separarlo del resto | ✅/⚠️ |
| C | `UPDATE` masivo de toda la tabla en una sola transacción, sin lotes; además no es idempotente con nuevos pagos | ❌ |
| D | Sin rollback documentado | ⚠️ |
| E | Nombres no siguen convenciones: `invoices_status_idx` → `ix_invoices__status`; `invoice_lines_invoice_fk` → `fk_invoice_lines__invoices` | ⚠️ |
| E | `ON DELETE CASCADE` prohibido en facturación | ❌ |
| E | `varchar(20)` para estado: valorar `CHECK` con valores permitidos | ⚠️ |

**Veredicto: RECHAZADA.**

Versión corregida (dividida en tres migraciones):

```sql
-- V202611250900__add_status_to_invoices.sql
SET lock_timeout = '3s';
ALTER TABLE invoices ADD COLUMN status varchar(20) NOT NULL DEFAULT 'pending';
ALTER TABLE invoices ADD CONSTRAINT ck_invoices__status_valid
  CHECK (status IN ('pending', 'paid', 'cancelled')) NOT VALID;
ALTER TABLE invoice_lines
  ADD CONSTRAINT fk_invoice_lines__invoices
  FOREIGN KEY (invoice_id) REFERENCES invoices (id) NOT VALID;

-- V202611250901__validate_constraints.sql
ALTER TABLE invoices VALIDATE CONSTRAINT ck_invoices__status_valid;
ALTER TABLE invoice_lines VALIDATE CONSTRAINT fk_invoice_lines__invoices;

-- V202611250902__index_status.sql  (sin transacción: en Flyway, executeInTransaction=false)
CREATE INDEX CONCURRENTLY IF NOT EXISTS ix_invoices__status ON invoices (status);
```

El backfill del estado `paid` se hace fuera de la migración, por lotes e idempotente:

```sql
UPDATE invoices i SET status = 'paid'
WHERE i.id IN (
  SELECT i2.id FROM invoices i2
  JOIN payments p ON p.invoice_id = i2.id
  WHERE i2.status = 'pending'
  LIMIT 10000
);
-- repetir hasta 0 filas afectadas
```

Pregunta 6.4: el agente no puede editar porque su `tools` solo incluye `Read, Grep, Glob`;
no tiene la herramienta `Edit` disponible.

### Ejercicio 6, punto 6 — Modo líder

| Petición | Agente esperado | Por qué |
|---|---|---|
| (a) ¿Qué tablas tocan las migraciones? | `explorador` (Haiku) | Solo leer y listar |
| (b) Escribe la versión corregida | `implementador` (Sonnet), quizá tras `revisor-migraciones` | Hay que crear y modificar ficheros |
| (c) Diseña el particionado por mes de `invoices` | `especialista` (Fable) | Diseño de alto riesgo en tabla > 50 GB |

Si el líder hace (a) él mismo, no es un error grave: para lecturas muy cortas delegar no compensa.
Si usa `especialista` para (a) o (b), revisa las `description` de los agentes.

### Ejercicio 6, punto 7 — Clasificación

| Tarea | Agente |
|---|---|
| Buscar dónde se usa `invoice_lines.discount` | explorador |
| Añadir una columna `notes` | implementador |
| Deadlock que aparece una vez por semana | especialista |
| Renombrar un índice | implementador (con revisor-migraciones si la tabla es grande) |
| Diseñar la réplica lógica hacia el data warehouse | especialista |
| "¿Qué versión de PostgreSQL usamos?" | El líder (está en el CLAUDE.md; delegar no compensa) |

## Ejercicio 7.1 — Casos que el hook no detecta

- `psql -f borrar.sql` (el SQL está en un fichero).
- `psql -c "$SQL"` (el SQL está en una variable).
- `echo 'DROP TABLE x' | psql` → este sí se detecta (el texto está en el comando), pero
  `cat borrar.sql | psql` no.
- `DELETE FROM x WHERE true` (tiene WHERE pero borra todo).

Cobertura: leer los ficheros pasados con `-f`/`<`, bloquear `-c "$VAR"` cuando la variable no se
pueda resolver, y sobre todo confiar en el rol de solo lectura.

## Ejercicio 11.2

Con la migración de ejemplo el veredicto es `RECHAZADA`, por lo que el script sale con `exit 1`.
