# Curso: Claude Code CLI para equipos DBA

**De los métodos del equipo a skills y agentes compartidos**

Curso práctico para montar Claude Code en un equipo de administradores de bases de datos que
ya tiene sus propios métodos de trabajo (checklists, runbooks, consultas de diagnóstico,
plantillas de RFC) y quiere convertirlos en **skills** reutilizables y en **agentes
especializados** que todo el equipo use igual, de forma segura y versionada.

Este repositorio es a la vez **el curso** y **la implementación de referencia**: un
marketplace de plugins listo para clonar y adaptar.

## A quién va dirigido

- DBAs (PostgreSQL, Oracle, SQL Server, MySQL…) que usan la terminal a diario.
- El responsable técnico que va a desplegar Claude Code al equipo.
- No hace falta saber programar más allá de shell y SQL. Los ejemplos usan PostgreSQL,
  pero cada módulo explica cómo trasladarlo a otros motores.

## Temario

| # | Módulo | Resultado al terminar |
|---|---|---|
| 1 | [Conceptos: las piezas de Claude Code](curso/01-conceptos.md) | Sabes qué pieza usar para cada necesidad del equipo |
| 2 | [Instalación y primer arranque](curso/02-instalacion.md) | Claude Code funcionando y sabes qué superficie usar (CLI, IDE, web) |
| 3 | [Configuración y permisos](curso/03-configuracion-permisos.md) | Jerarquía de settings y permisos seguros para DBAs |
| 4 | [Memoria del proyecto: CLAUDE.md](curso/04-claude-md.md) | Claude conoce el contexto de cada base de datos |
| 5 | [Skills: convertir métodos en skills](curso/05-skills.md) | Tus primeros métodos convertidos en skills |
| 6 | [Subagentes con skills propias](curso/06-subagentes.md) | Sabes crear y configurar agentes paso a paso y aplicar el patrón líder (Haiku lee, Sonnet escribe, Fable para lo difícil) |
| 7 | [Hooks: guardarraíles automáticos](curso/07-hooks.md) | SQL destructivo bloqueado aunque el modelo se equivoque |
| 8 | [MCP y conexión a bases de datos](curso/08-mcp-bases-de-datos.md) | Acceso a datos controlado y de solo lectura |
| 9 | [Distribución: plugins y marketplace del equipo](curso/09-plugins-marketplace.md) | Todo el equipo instala lo mismo con un comando |
| 10 | [Evals: probar que las skills funcionan](curso/10-evals.md) | Pruebas automáticas de tus skills |
| 11 | [Automatización: modo headless y CI](curso/11-automatizacion-ci.md) | Revisión automática de migraciones en cada PR |
| 12 | [Gobernanza y plan de adopción](curso/12-gobernanza-adopcion.md) | Plan de despliegue en 4 semanas y reglas de mantenimiento |
| — | [Soluciones de los ejercicios](curso/soluciones.md) | |

Duración orientativa: **2 jornadas** (módulos 1–6 el primer día, 7–12 el segundo).

## Estructura del repositorio

```
.
├── .claude-plugin/marketplace.json     ← el repo es un marketplace ("dba-team")
├── plugins/
│   ├── dba-core/                       ← métodos comunes a cualquier motor
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/                     ← 4 skills (planes, migraciones, triage, RFC)
│   │   ├── agents/                     ← revisor-migraciones, analista-rendimiento
│   │   ├── hooks/                      ← bloqueo de SQL destructivo
│   │   └── evals/                      ← pruebas de las skills
│   └── dba-postgres/                   ← runbooks específicos de PostgreSQL
│       ├── skills/                     ← pg-salud, pg-bloqueos (+ ficheros .sql)
│       └── agents/                     ← guardia-postgres
├── ejemplo-proyecto/                   ← un repo de aplicación que consume el marketplace
│   ├── CLAUDE.md
│   ├── .claude/settings.json           ← permisos + plugins habilitados para todo el equipo
│   ├── .claude/skills/                 ← skill propia del proyecto
│   ├── .claude/agents/                 ← agentes del proyecto: auditor, explorador, implementador, especialista
│   ├── .mcp.json
│   └── migrations/                     ← migración con errores para los ejercicios
├── extras/config-personal/             ← patrón líder para tu ~/.claude (uso general)
└── curso/                              ← los módulos
```

## Arranque rápido (5 minutos)

```bash
# 1. Prueba los plugins sin instalarlos
git clone <url-de-este-repo> curso-claude-dba && cd curso-claude-dba/ejemplo-proyecto
claude --plugin-dir ../plugins/dba-core --plugin-dir ../plugins/dba-postgres

# 2. Dentro de Claude Code
> /agents                                   # verás revisor-migraciones, analista-rendimiento…
> revisa la migración de migrations/ con el revisor de migraciones
> /dba-core:solicitud-cambio-produccion añadir índice en invoices(customer_id)
```

Versión de referencia usada al escribir el curso: Claude Code 2.1.x. Las piezas cambian rápido:
ante la duda, consulta la documentación oficial en https://code.claude.com/docs.
