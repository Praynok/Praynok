# Módulo 3 — Configuración y permisos

> **Objetivo:** entender la jerarquía de configuración y diseñar permisos seguros para
> trabajo con bases de datos.

## 3.1 Jerarquía de settings

De **mayor a menor** prioridad:

| Nivel | Fichero | Quién lo controla | Se comparte |
|---|---|---|---|
| Gestionado (empresa) | Consola de administración, o `/etc/claude-code/managed-settings.json` (Linux), `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS), `C:\Program Files\ClaudeCode\managed-settings.json` (Windows) | IT / responsable del equipo | Sí, no se puede sobrescribir |
| Argumentos de línea de comandos | `--settings`, `--allowedTools`… | Quien lanza | No |
| Local del proyecto | `.claude/settings.local.json` | Cada persona (en `.gitignore`) | No |
| Proyecto | `.claude/settings.json` | El equipo, en git | Sí |
| Usuario | `~/.claude/settings.json` | Cada persona | No |

Las reglas **deny** ganan siempre, vengan del nivel que vengan.

## 3.2 Permisos

Tres listas: `allow` (sin preguntar), `ask` (pregunta siempre), `deny` (prohibido).

```json
{
  "permissions": {
    "allow": ["Read", "Grep", "Glob", "Bash(psql:*)", "Bash(git diff:*)"],
    "ask":   ["Bash(pg_dump:*)", "Edit(migrations/**)"],
    "deny":  ["Read(./.env)", "Read(~/.pgpass)", "Bash(dropdb:*)", "Bash(psql*prod*)"]
  }
}
```

Sintaxis útil:

| Regla | Significado |
|---|---|
| `Bash(psql:*)` | Cualquier comando que empiece por `psql` |
| `Bash(git log:*)` | `git log` con cualquier argumento |
| `Bash(psql*prod*)` | Comodín: cualquier `psql` que mencione "prod" |
| `Read(./.env)` | Un fichero concreto (relativo al proyecto) |
| `Edit(migrations/**)` | Cualquier fichero bajo `migrations/` |
| `mcp__postgres-staging__*` | Todas las herramientas de un servidor MCP |

> ⚠️ Los permisos sobre Bash se basan en el **texto** del comando. `Bash(psql:*)` en allow
> permite también `psql -c "DROP TABLE..."`. Por eso, en un equipo DBA los permisos **no
> bastan**: se combinan con (1) roles de base de datos de solo lectura y (2) un hook que
> inspecciona el SQL (módulo 7). Defensa en profundidad.

## 3.3 La regla de oro: el control de verdad está en la base de datos

Crea un rol específico para Claude en cada entorno al que vaya a acceder:

```sql
-- PostgreSQL
CREATE ROLE claude_ro LOGIN PASSWORD '...' CONNECTION LIMIT 5;
ALTER ROLE claude_ro SET default_transaction_read_only = on;
ALTER ROLE claude_ro SET statement_timeout = '30s';
ALTER ROLE claude_ro SET idle_in_transaction_session_timeout = '60s';
GRANT pg_monitor TO claude_ro;                 -- vistas de estadísticas y actividad
GRANT CONNECT ON DATABASE billing TO claude_ro;
-- Solo si necesita leer datos de negocio (valóralo con seguridad):
-- GRANT pg_read_all_data TO claude_ro;
```

```sql
-- Oracle (orientativo)
CREATE USER claude_ro IDENTIFIED BY "..." PROFILE perfil_limitado;
GRANT CREATE SESSION, SELECT_CATALOG_ROLE TO claude_ro;
```

```sql
-- SQL Server (orientativo)
CREATE LOGIN claude_ro WITH PASSWORD = '...';
GRANT VIEW SERVER STATE, VIEW ANY DEFINITION TO claude_ro;
```

`PGAPPNAME=claude-code` (en `env` de settings) hace que las sesiones de Claude sean
identificables en `pg_stat_activity` y en la auditoría.

## 3.4 Credenciales

- Nunca en CLAUDE.md, skills ni `settings.json` versionado.
- Usa variables de entorno (`PG_RO_URL`) cargadas por cada DBA, un `.pgpass` (denegado para
  lectura a Claude) o el gestor de secretos de la empresa.
- Deniega explícitamente la lectura de `.env`, `.pgpass`, `tnsnames.ora` con credenciales, etc.

## 3.5 Settings gestionados para el equipo

El responsable del equipo puede imponer reglas que nadie puede desactivar. Ejemplo
`managed-settings.json`:

```json
{
  "permissions": {
    "deny": ["Bash(dropdb:*)", "Bash(psql*prod*)", "Read(**/.pgpass)"],
    "disableBypassPermissionsMode": "disable"
  },
  "extraKnownMarketplaces": {
    "dba-team": { "source": { "source": "github", "repo": "tu-org/claude-dba" } }
  },
  "enabledPlugins": { "dba-core@dba-team": true },
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "tu-org/claude-dba" }
  ]
}
```

- `disableBypassPermissionsMode`: impide arrancar con `--dangerously-skip-permissions`.
- `strictKnownMarketplaces`: solo se pueden añadir los marketplaces aprobados.
- `enabledPlugins` + `extraKnownMarketplaces`: el plugin del equipo viene puesto.

## Ejercicio 3

1. Revisa [`ejemplo-proyecto/.claude/settings.json`](../ejemplo-proyecto/.claude/settings.json).
   ¿Qué pasa si Claude intenta `psql -h db-prod-01 ...`? ¿Y `cat .env`?
2. Crea tu `.claude/settings.local.json` con un permiso personal (por ejemplo
   `Bash(pgbadger:*)`) y comprueba con `/permissions` de dónde viene cada regla.
3. Escribe el `CREATE ROLE` de solo lectura para tu motor principal.
