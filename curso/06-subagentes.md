# Módulo 6 — Subagentes con skills propias

> **Objetivo:** crear agentes especializados (revisor, analista, guardia…) que llevan
> precargadas las skills del equipo y tienen solo las herramientas que necesitan.

## 6.1 Qué es un subagente

Un subagente es un asistente con:
- su **propio contexto** (no contamina la conversación principal; solo devuelve el resultado final),
- su **prompt de sistema** (el rol),
- su lista de **herramientas** permitidas,
- su **modelo** (puede ser más barato o más potente que el principal),
- sus **skills precargadas**.

Claude delega en él automáticamente cuando la tarea encaja con su `description`, o cuando
se lo pides: *"usa el agente revisor-migraciones para revisar migrations/"*.

## 6.2 Anatomía

Fichero Markdown con frontmatter, en `.claude/agents/`, `~/.claude/agents/` o en la carpeta
`agents/` de un plugin:

```markdown
---
name: revisor-migraciones
description: Revisor de migraciones de esquema del equipo DBA. Úsalo de forma proactiva
  cuando se creen o modifiquen ficheros de migración...
tools: Read, Grep, Glob          # si se omite, hereda todas las herramientas
model: sonnet                    # sonnet | opus | haiku | inherit
skills:                          # skills que se cargan al arrancar el agente
  - revision-migracion
color: blue
---

Eres un DBA senior especializado en cambios de esquema sin parada de servicio.
Tu único trabajo es revisar: nunca editas ficheros ni ejecutas nada...
```

| Campo | Notas |
|---|---|
| `name` | Identificador único |
| `description` | Cuándo delegar. Añade "úsalo de forma proactiva" si quieres que Claude delegue sin que se lo pidan |
| `tools` | **Principio de mínimo privilegio**. Un revisor no necesita `Bash` ni `Edit` |
| `model` | `haiku` para tareas mecánicas (auditar nombres), `sonnet`/`opus` para diagnóstico |
| `skills` | Las skills del equipo que este rol aplica siempre |
| `permissionMode` | Opcional. P. ej. `plan` para que nunca modifique nada |

## 6.3 Skills + agentes: el diseño del equipo

Piensa en **skills = métodos** y **agentes = roles**. Varias skills se reutilizan en varios roles:

| Agente | Herramientas | Modelo | Skills precargadas | Dónde |
|---|---|---|---|---|
| `revisor-migraciones` | Read, Grep, Glob | sonnet | `revision-migracion` | plugin `dba-core` |
| `analista-rendimiento` | Read, Grep, Glob, Bash | inherit | `diagnostico-rendimiento`, `analisis-plan-ejecucion` | plugin `dba-core` |
| `guardia-postgres` | Read, Grep, Glob, Bash | inherit | `pg-salud`, `pg-bloqueos` | plugin `dba-postgres` |
| `auditor-modelo-datos` | Read, Grep, Glob | haiku | `convenciones-esquema` | repo del proyecto |

Observa el último: un **agente del proyecto** que usa una **skill del proyecto**. Cada equipo
de producto puede tener sus agentes propios encima de los del equipo DBA.

¿Por qué precargar skills si Claude puede descubrirlas solo? Porque un subagente arranca con
contexto limpio: precargarlas garantiza que el rol aplique **siempre** el método del equipo,
en lugar de depender de que elija bien.

> En agentes de un plugin, las skills se referencian por su nombre. Si en tu versión no se
> cargan, prueba con el nombre con namespace (`dba-core:revision-migracion`) y verifica con
> `/agents`.

## 6.4 Crear agentes

**Con el asistente:** `/agents` → *Create new agent* → elige ámbito (proyecto o usuario),
describe el rol y deja que Claude genere el borrador. Después edítalo a mano para afinar
`tools`, `model` y `skills`.

**A mano:** crea el `.md` en `.claude/agents/`. Se recarga al reiniciar la sesión.

**Al vuelo (scripts/CI):**
```bash
claude --agents '{
  "revisor-rapido": {
    "description": "Revisa una migración",
    "prompt": "Eres un revisor DBA. Aplica la skill revision-migracion.",
    "tools": ["Read","Grep","Glob"],
    "model": "haiku"
  }
}'
```

## 6.5 Buenas prácticas

- **Un rol, una responsabilidad.** "Revisor" y "ejecutor" nunca en el mismo agente.
- **El agente debe devolver un informe autocontenido**: el agente principal solo ve su respuesta final.
- **Repite los límites en el prompt** aunque haya hooks ("nunca ejecutas DDL").
  Hooks y permisos son la red; el prompt evita que lo intente.
- **Paraleliza**: *"lanza tres revisor-migraciones en paralelo, uno por carpeta"*.
- Los subagentes no lanzan otros subagentes: la orquestación la hace la sesión principal.

## Ejercicio 6

1. Entra en `ejemplo-proyecto/` con los plugins cargados y pide:
   *"revisa la migración nueva de migrations/"*. Comprueba con el indicador de la sesión que
   delega en `revisor-migraciones`. Compara con [la solución](soluciones.md#ejercicio-6).
2. Pide *"audita el modelo de datos"* y verifica que usa `auditor-modelo-datos` (haiku).
3. Crea tu propio agente `capacidad` con la skill del ejercicio 5.4, herramientas
   `Read, Bash` y modelo `haiku`.
4. Intenta que `revisor-migraciones` edite un fichero. ¿Qué pasa y por qué?
