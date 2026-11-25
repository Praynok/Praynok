# dba-postgres

Runbooks de PostgreSQL. Recomendado junto a `dba-core`.

| Tipo | Nombre | Uso |
|---|---|---|
| Skill | `pg-salud` | Chequeo de salud completo (6 consultas de catálogo) |
| Skill | `pg-bloqueos` | Árbol de bloqueos y causa raíz |
| Agente | `guardia-postgres` | DBA de guardia: salud + bloqueos, solo lectura |

Requiere la variable `PG_RO_URL` con una conexión de un rol de solo lectura.
