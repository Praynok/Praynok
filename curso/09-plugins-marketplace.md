# Módulo 9 — Distribución: plugins y marketplace del equipo

> **Objetivo:** que todo el equipo tenga las mismas skills, agentes y hooks, en la misma
> versión, con un comando, y que mejorarlos sea un PR.

## 9.1 Por qué plugins

Copiar carpetas `.claude/skills` entre repos no escala: cada copia diverge. Un **plugin**
empaqueta skills + agentes + hooks + MCP, se versiona, y se instala desde un **marketplace**
(un repo git con un catálogo). Este repositorio es exactamente eso.

## 9.2 Estructura de un plugin

```
plugins/dba-core/
├── .claude-plugin/
│   └── plugin.json          ← manifest: name, version, description, author
├── skills/<skill>/SKILL.md
├── agents/<agente>.md
├── hooks/hooks.json         ← + scripts referenciados con ${CLAUDE_PLUGIN_ROOT}
├── .mcp.json                ← opcional
├── evals/                   ← opcional (módulo 10)
└── README.md
```

```json
{
  "name": "dba-core",
  "version": "1.0.0",
  "description": "Métodos DBA independientes del motor, agentes revisores y hooks de seguridad.",
  "author": { "name": "Equipo DBA" }
}
```

Al instalarlo, sus skills se invocan con namespace: `/dba-core:solicitud-cambio-produccion`.

## 9.3 El marketplace

[`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json) en la raíz del repo:

```json
{
  "name": "dba-team",
  "owner": { "name": "Equipo DBA" },
  "plugins": [
    { "name": "dba-core",     "source": "./plugins/dba-core",     "description": "..." },
    { "name": "dba-postgres", "source": "./plugins/dba-postgres", "description": "..." }
  ]
}
```

**Cómo dividir en plugins:** uno común (`dba-core`) y uno por motor (`dba-postgres`,
`dba-oracle`, `dba-sqlserver`…). Cada DBA habilita los de los motores que administra, y no
paga en contexto las skills que no usa.

## 9.4 Ciclo de desarrollo

```bash
# 1. Desarrollar y probar sin instalar
claude --plugin-dir ./plugins/dba-core

# 2. Validar manifest, frontmatter de skills y agentes
claude plugin validate .                    # el marketplace
claude plugin validate ./plugins/dba-core   # un plugin

# 3. Inventario y coste en contexto
claude --plugin-dir ./plugins/dba-core plugin details dba-core

# 4. Evals (módulo 10)
claude plugin eval ./plugins/dba-core

# 5. Subir versión en plugin.json (y marketplace.json), PR, revisión por otro DBA, merge
# 6. Etiquetar la release (valida que plugin.json y marketplace coinciden)
claude plugin tag ./plugins/dba-core
```

Salida real de `plugin details` para `dba-core` en este repo:

```
Component inventory
  Skills (4)  analisis-plan-ejecucion, diagnostico-rendimiento, revision-migracion, solicitud-cambio-produccion
  Agents (2)  revisor-migraciones, analista-rendimiento
  Hooks (1)  PreToolUse  (harness-only — no model context cost)
Projected token cost
  Always-on:   ~685 tok   added to every session
```

## 9.5 Instalación por parte de cada DBA

```bash
# En la terminal
claude plugin marketplace add tu-org/claude-dba     # repo GitHub (o URL git, o ruta local)
claude plugin install dba-core@dba-team
claude plugin install dba-postgres@dba-team

# O dentro de una sesión
/plugin marketplace add tu-org/claude-dba
/plugin                                             # menú interactivo para instalar
```

Actualizar: `claude plugin marketplace update dba-team` y `claude plugin update dba-core@dba-team`.

## 9.6 Instalación automática por proyecto

Mejor aún: que el repo de cada sistema declare qué necesita. En su `.claude/settings.json`
([ejemplo](../ejemplo-proyecto/.claude/settings.json)):

```json
{
  "extraKnownMarketplaces": {
    "dba-team": { "source": { "source": "github", "repo": "tu-org/claude-dba" } }
  },
  "enabledPlugins": {
    "dba-core@dba-team": true,
    "dba-postgres@dba-team": true
  }
}
```

Quien abra el proyecto y confíe en la carpeta recibirá la propuesta de instalar el
marketplace y los plugins. Para imponerlo a toda la organización, pon lo mismo en los
settings gestionados (módulo 3.5) junto con `strictKnownMarketplaces`.

## 9.7 Versionado y compatibilidad

- **SemVer**: cambio de formato de salida de una skill = versión mayor (rompe informes o CI
  que dependan de él). Nueva skill = menor. Corrección = parche.
- Mantén un `CHANGELOG.md` por plugin.
- Repos privados: el marketplace funciona con cualquier repo git al que el DBA tenga acceso
  con sus credenciales de git.

## Ejercicio 9

1. Haz fork/copia de este repo en tu organización y cambia `praynok/praynok` por tu repo en
   `ejemplo-proyecto/.claude/settings.json`.
2. Instala `dba-core` desde tu marketplace y comprueba `/plugin` y `/agents`.
3. Crea el plugin `dba-<tu-motor>` con una skill y un agente, regístralo en
   `marketplace.json`, valida y publica la versión 0.1.0.
4. Cambia la descripción de una skill, sube la versión de parche y actualiza en otro equipo.
