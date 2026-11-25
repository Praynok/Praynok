# Módulo 5 — Skills: convertir los métodos del equipo en skills

> **Objetivo:** escribir skills que Claude use en el momento justo y que produzcan
> exactamente el resultado que el equipo espera.

## 5.1 Anatomía de una skill

```
analisis-plan-ejecucion/          ← el nombre de la carpeta = nombre de la skill
├── SKILL.md                      ← obligatorio: frontmatter + instrucciones
├── patrones.md                   ← apoyo: se lee solo si SKILL.md lo enlaza y hace falta
└── sql/ , plantillas/ , scripts/ ← apoyo: consultas, plantillas, scripts ejecutables
```

```markdown
---
name: analisis-plan-ejecucion
description: Método del equipo DBA para analizar planes de ejecución (EXPLAIN ...).
  Úsala cuando el usuario pegue un plan de ejecución, pregunte por qué una consulta
  es lenta, o pida recomendar índices.
allowed-tools: Read, Grep, Glob          # opcional
---

# Instrucciones en Markdown
...
```

### Campos del frontmatter

| Campo | Obligatorio | Para qué |
|---|---|---|
| `name` | Sí | Identificador (minúsculas, guiones). Es también el comando `/nombre` |
| `description` | Sí | **Cuándo** usarla. Claude decide con esto si la carga |
| `allowed-tools` | No | Herramientas que la skill puede usar sin pedir permiso mientras está activa |
| `disable-model-invocation` | No | `true` = solo se invoca a mano con `/nombre` (para acciones con efectos) |
| `argument-hint` | No | Pista de argumentos que se muestra al escribir `/nombre` |
| `model` | No | Forzar un modelo para esta skill |

Dentro del cuerpo, `$ARGUMENTS` se sustituye por lo que se escriba tras `/nombre`.

## 5.2 Dónde viven

| Ubicación | Alcance | Cómo se invoca |
|---|---|---|
| `~/.claude/skills/<nombre>/` | Personal, todos tus proyectos | `/nombre` |
| `<repo>/.claude/skills/<nombre>/` | Todo el que trabaje en ese repo | `/nombre` |
| Plugin `skills/<nombre>/` | Quien tenga el plugin habilitado | `/plugin:nombre` (con namespace) |

**Estrategia para un equipo DBA:**
- Métodos comunes del equipo → **plugin** (módulo 9). Se versionan y se actualizan para todos.
- Particularidades de un sistema (convenciones de un esquema) → `.claude/skills/` del repo
  de ese sistema. Ejemplo: [`convenciones-esquema`](../ejemplo-proyecto/.claude/skills/convenciones-esquema/SKILL.md).
- Experimentos personales → `~/.claude/skills/`, y cuando funcionen, se proponen al plugin.

## 5.3 La descripción: lo más importante

Claude elige skills **solo por su descripción**. Una buena descripción dice *qué hace* y,
sobre todo, *cuándo usarla*, con las palabras que usaría el DBA:

| ❌ Mala | ✅ Buena |
|---|---|
| `Ayuda con planes.` | `Método del equipo para analizar planes de ejecución (EXPLAIN, EXPLAIN ANALYZE, planes de Oracle o SQL Server). Úsala cuando el usuario pegue un plan, pregunte por qué una consulta es lenta o pida índices.` |
| `Checklist de migraciones.` | `Checklist para revisar migraciones de esquema (Flyway, Liquibase, Alembic, DDL). Úsala al revisar, aprobar o escribir una migración o al preguntar si un cambio de esquema es seguro.` |

Consejos:
- Incluye sinónimos y nombres de herramientas (`Flyway`, `AWR`, `pg_stat_statements`).
- Evita solapes: si dos skills tienen descripciones parecidas, Claude dudará.
- En tercera persona/infinitivo, concreta, menos de ~1.000 caracteres.

## 5.4 Del método a la skill: proceso en 6 pasos

Tomemos el checklist de migraciones que tu equipo tiene en la wiki.

1. **Recopila** el método tal como lo aplicáis hoy (wiki, Excel, el correo de "cosas a mirar").
2. **Hazlo ejecutable**: convierte cada punto en una comprobación verificable
   ("¿`CREATE INDEX` sin `CONCURRENTLY` sobre tabla > 1 GB?" en lugar de "cuidado con los índices").
3. **Define el formato de salida**: tabla, veredicto, plantilla. Así todos los informes
   del equipo son comparables.
4. **Separa lo largo en ficheros de apoyo** (tablas de patrones, consultas SQL, plantillas)
   y enlázalos desde SKILL.md. Mantén SKILL.md por debajo de ~500 líneas.
5. **Pon límites explícitos**: qué NO debe hacer ("nunca mates sesiones").
6. **Prueba** con casos reales (y automatízalo con evals, módulo 10).

Resultado: [`plugins/dba-core/skills/revision-migracion/`](../plugins/dba-core/skills/revision-migracion/SKILL.md).

## 5.5 Patrones de skills útiles para DBAs

| Patrón | Ejemplo en este repo | Clave |
|---|---|---|
| **Checklist** con veredicto | `revision-migracion` | Estados ✅/⚠️/❌ y reglas de veredicto |
| **Runbook** con árbol de decisión | `diagnostico-rendimiento` | Tabla "si ves X → haz Y" |
| **Biblioteca de consultas** | `pg-salud`, `pg-bloqueos` | Ficheros `.sql` probados + umbrales de alerta |
| **Plantilla documental**, invocación manual | `solicitud-cambio-produccion` | `disable-model-invocation: true` + `$ARGUMENTS` |
| **Conocimiento del sistema** | `convenciones-esquema` | Vive en el repo del proyecto, no en el plugin |

### Skills con consultas SQL

Guardar las consultas en ficheros `.sql` en lugar de dentro del Markdown tiene tres ventajas:
se pueden probar con `psql -f` fuera de Claude, se revisan en PRs como código, y Claude
las ejecuta tal cual en lugar de "reescribirlas de memoria". Combínalo con
`allowed-tools: Read, Bash(psql:*)` para que la skill pueda ejecutarlas sin pedir permiso
cada vez (el hook y el rol de solo lectura siguen protegiendo).

### Skills que solo se invocan a mano

Todo lo que genere un artefacto con consecuencias (RFC, comunicación a negocio, informe para
auditoría) debe llevar `disable-model-invocation: true`: así solo se ejecuta cuando un DBA
lo pide con `/dba-core:solicitud-cambio-produccion ...`.

## 5.6 Probar una skill

```bash
# Sin instalar nada: cargar el plugin desde disco
claude --plugin-dir ./plugins/dba-core

# Validar la estructura (frontmatter, nombres, manifest)
claude plugin validate ./plugins/dba-core

# Ver coste en contexto de cada skill
claude --plugin-dir ./plugins/dba-core plugin details dba-core
```

Prueba de activación: escribe un prompt *sin* nombrar la skill (por ejemplo pegando un plan)
y comprueba que Claude la carga. Si no lo hace, mejora la descripción.

## Ejercicio 5

1. Toma uno de los métodos de tu inventario del ejercicio 1 y conviértelo en una skill
   siguiendo 5.4, en `~/.claude/skills/`.
2. Escribe dos descripciones alternativas y prueba cuál se activa mejor con 5 prompts distintos.
3. Si el método incluye consultas, sácalas a `sql/` y enlázalas.
4. Crea una skill de invocación manual (`disable-model-invocation: true`) que genere el
   informe semanal de capacidad con `$ARGUMENTS` como nombre de la instancia.
