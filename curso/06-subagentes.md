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
model: sonnet                    # haiku | sonnet | opus | fable | inherit
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
| `model` | `haiku` para leer y tareas mecánicas, `sonnet` para escribir, `opus`/`fable` para diagnóstico difícil (6.6) |
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
| `explorador` | Read, Grep, Glob | haiku | — | repo del proyecto (6.6) |
| `implementador` | Read, Grep, Glob, Edit, Write | sonnet | `convenciones-esquema` | repo del proyecto (6.6) |
| `especialista` | Read, Grep, Glob, Bash | fable | `analisis-plan-ejecucion`, `revision-migracion` | repo del proyecto (6.6) |

Observa el último: un **agente del proyecto** que usa una **skill del proyecto**. Cada equipo
de producto puede tener sus agentes propios encima de los del equipo DBA.

¿Por qué precargar skills si Claude puede descubrirlas solo? Porque un subagente arranca con
contexto limpio: precargarlas garantiza que el rol aplique **siempre** el método del equipo,
en lugar de depender de que elija bien.

> En agentes de un plugin, las skills se referencian por su nombre. Si en tu versión no se
> cargan, prueba con el nombre con namespace (`dba-core:revision-migracion`) y verifica con
> `/agents`.

## 6.4 Guía paso a paso: crear y configurar un agente

### Paso 1 — Decide el ámbito (dónde vive el fichero)

| Ámbito | Ruta | Quién lo ve | Úsalo para |
|---|---|---|---|
| Proyecto | `<repo>/.claude/agents/<nombre>.md` | Todo el que trabaje en el repo (va en git) | Roles ligados a un sistema (`auditor-modelo-datos`) |
| Usuario | `~/.claude/agents/<nombre>.md` | Solo tú, en todos tus proyectos | Tus roles personales (ver [extras/config-personal](../extras/config-personal/README.md)) |
| Plugin | `<plugin>/agents/<nombre>.md` | Quien tenga el plugin habilitado | Roles comunes del equipo (`revisor-migraciones`) |
| Línea de comandos | `claude --agents '<json>'` | Solo esa ejecución | CI y pruebas rápidas |

**Si dos agentes se llaman igual**, gana el de mayor prioridad: línea de comandos → proyecto →
usuario → plugin. Esto incluye a los **agentes que Claude Code trae de serie** (`Explore`,
`Plan`, `general-purpose`…): si creas un fichero con `name: Explore`, sustituyes al integrado.
Es posible, pero en un equipo lo desaconsejamos: el comportamiento cambia sin que nadie lo vea
y la documentación oficial deja de coincidir con lo que pasa. Usa nombres propios
(`explorador`, `implementador`) y, si quieres que se usen en lugar de los integrados, dilo en
el CLAUDE.md (apartado 6.6).

### Paso 2 — Crea el fichero

**Opción A, con el asistente (recomendado la primera vez):**
1. En la sesión, escribe `/agents`.
2. Elige *Create new agent* y el ámbito (*Project* o *Personal*).
3. Elige *Generate with Claude* y describe el rol en una o dos frases
   ("revisor de migraciones Flyway, solo lectura, aplica nuestro checklist").
4. Selecciona las herramientas permitidas en la lista y el modelo.
5. Guarda. El asistente crea el `.md`; ábrelo y afínalo a mano (pasos 3 y 4).

**Opción B, a mano:** crea el fichero `.claude/agents/<nombre>.md` con la plantilla:

```markdown
---
name: nombre-del-agente
description: Qué hace y CUÁNDO usarlo, con las palabras que usaría el DBA.
tools: Read, Grep, Glob
model: sonnet
skills:
  - skill-del-equipo
color: blue
---

Prompt de sistema: quién eres, qué haces, qué NO haces y cómo devuelves el resultado.
```

### Paso 3 — Configura el frontmatter

| Campo | Valores | Consejo |
|---|---|---|
| `name` | minúsculas y guiones | Único; es como lo invocas ("usa el agente `revisor-migraciones`") |
| `description` | texto | Lo más importante, igual que en las skills: Claude delega **solo** por esto. Di cuándo usarlo y cuándo **no**. "Úsalo de forma proactiva" hace que delegue sin que se lo pidas |
| `tools` | lista separada por comas | Si lo omites, **hereda todas** (incluidas las de MCP). Ponlo siempre en un equipo DBA |
| `disallowedTools` | lista | Alternativa: heredar todo menos lo que listes (p. ej. `Edit, Write`) |
| `model` | `haiku`, `sonnet`, `opus`, `fable`, `inherit` o un ID completo (`claude-fable-5-2`) | `inherit` = el mismo que la sesión. Ver tabla de 6.6 |
| `skills` | lista de nombres de skill | Se cargan al arrancar el agente, garantizando que aplique el método |
| `permissionMode` | `default`, `acceptEdits`, `plan`… | `plan` para agentes que nunca deben modificar nada |
| `color` | `blue`, `green`, `red`… | Para distinguir en pantalla qué agente está trabajando |

Herramientas habituales y qué permiten:

| Herramienta | Permite | ¿Darla a…? |
|---|---|---|
| `Read`, `Grep`, `Glob` | Leer y buscar ficheros | Casi todos |
| `Edit`, `Write` | Modificar y crear ficheros | Solo a quien escribe (implementador) |
| `Bash` | Ejecutar comandos (`psql`…) | Solo a quien diagnostica contra la BD; siempre con hook y rol de solo lectura |
| `WebFetch`, `WebSearch` | Consultar la web | Rara vez en un equipo DBA |
| `mcp__<servidor>__<herramienta>` | Herramientas MCP concretas | Solo las necesarias |

### Paso 4 — Escribe el prompt de sistema (el cuerpo)

Estructura que funciona:
1. **Rol** en una frase ("Eres el DBA de guardia de PostgreSQL").
2. **Procedimiento** numerado (qué skill aplica primero, qué consulta después).
3. **Límites** explícitos ("nunca ejecutas DDL"), aunque haya hooks.
4. **Formato de entrega**: el agente principal solo ve la respuesta final, así que debe ser
   un informe autocontenido.
5. **Criterio de parada o de escalado** ("si fallas dos veces, para y explica por qué").

### Paso 5 — Carga, prueba y verifica

```bash
/agents                 # ¿aparece? ¿con qué ámbito, herramientas y modelo?
```

Los ficheros creados a mano se cargan al **iniciar la sesión**: si editas uno, reinicia
(`/exit` y `claude -c` para continuar la conversación).

Pruebas mínimas antes de compartirlo:
- **Delegación automática:** un prompt realista *sin* nombrar el agente. ¿Delega? Si no,
  mejora la `description`.
- **Invocación explícita:** "usa el agente X para…". Debe funcionar siempre.
- **Límites:** pídele algo que no debe hacer (editar, un DROP). Debe negarse o fallar por
  falta de herramienta.
- **Modelo:** comprueba en `/agents` que el modelo es el esperado. Si tu cuenta o versión no
  admite un alias (p. ej. `fable`), usa el ID completo.

### Paso 6 — Compártelo

- Proyecto: commit del `.md` en `.claude/agents/` y PR.
- Equipo: muévelo a un plugin del marketplace (módulo 9) y sube la versión.

### Definirlo al vuelo (scripts y CI)

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

## 6.6 Patrón líder: un modelo por rol

Idea: la sesión principal actúa de **líder**. Planifica, delega y revisa la calidad, y cada
tipo de trabajo va al modelo que lo hace bien al menor coste:

| Rol | Agente de referencia | Modelo | Herramientas | Por qué |
|---|---|---|---|---|
| Líder | La sesión principal | El de la sesión (p. ej. Opus) | Todas | Coordina y revisa; no gasta su contexto leyendo ficheros |
| Leer y buscar | [`explorador`](../ejemplo-proyecto/.claude/agents/explorador.md) | `haiku` | Read, Grep, Glob | Leer es mucho volumen y poca dificultad: el modelo más barato |
| Escribir | [`implementador`](../ejemplo-proyecto/.claude/agents/implementador.md) | `sonnet` | Read, Grep, Glob, Edit, Write | Buen equilibrio para escribir migraciones y scripts. Sin Bash: no ejecuta SQL |
| Lo difícil | [`especialista`](../ejemplo-proyecto/.claude/agents/especialista.md) | `fable` | Read, Grep, Glob, Bash | El modelo más capaz, para problemas que los demás no resuelven |

Precio orientativo por millón de tokens (entrada / salida), API de Anthropic, noviembre de 2026:

| Modelo | Entrada | Salida | Relativo a Sonnet |
|---|---|---|---|
| Haiku 5.5 | 0,10 $ | 0,50 $ | ~1/20 |
| Sonnet 5.5 | 2 $ | 10 $ | 1× |
| Opus 5.5 | 4 $ | 20 $ | 2× |
| Fable 5.2 | 8 $ | 40 $ | 4× |

Con un plan Team o Enterprise no se paga por token, pero los modelos caros consumen antes el
límite de uso. Los precios cambian: consulta la página oficial de precios.

### Cuándo merece la pena el especialista (Fable) en un equipo DBA

✅ Sí:
- Deadlocks intermitentes, condiciones de carrera o corrupción de datos que no se reproduce.
- Diseño de particionado, de replicación o de alta disponibilidad (failover, réplicas lógicas).
- Migraciones de alto riesgo en tablas de más de 50 GB sin parada y con rollback.
- Auditoría de roles y permisos, o revisión de los propios hooks de seguridad.
- Planes de ejecución que no mejoran tras un primer intento con Sonnet.
- Cuando el implementador ha fallado dos veces en la misma tarea.

❌ No:
- Leer ficheros, listar tablas, buscar dónde se usa una columna (explorador).
- Migraciones rutinarias, añadir una columna, documentar (implementador).
- Checklists ya definidos en una skill (revisor-migraciones).

### Activarlo: el mensaje del líder

Ponlo en el CLAUDE.md del proyecto (como en el [ejemplo](../ejemplo-proyecto/CLAUDE.md)) o pégalo
al empezar una sesión:

```markdown
## Modo líder (un modelo por rol)
Tú eres el líder y respondes de la calidad final. Delega así:
- Leer o buscar en el repo → `explorador` (Haiku).
- Escribir o modificar ficheros → `implementador` (Sonnet).
- Problemas difíciles o de alto riesgo → `especialista` (Fable). Es el más caro: úsalo solo en esos casos.
Intervén tú solo si un subagente se atasca, y revisa siempre su resultado antes de darlo por bueno.
```

Las `description` de los agentes refuerzan el reparto. El mensaje del líder lo hace explícito
y le da prioridad sobre los agentes integrados.

### Limitaciones

- Delegar tiene coste fijo: cada subagente arranca con contexto vacío y debe releer lo que necesite.
  Para tareas de dos minutos, que lo haga el líder directamente.
- El líder decide por las descripciones: si un agente no se usa cuando debería, ajusta su
  `description` antes de añadir más reglas al CLAUDE.md.
- Disponibilidad de modelos: no todas las cuentas o proveedores (Bedrock, Vertex…) tienen todos
  los modelos. Comprueba en `/agents` que cada agente muestra el modelo esperado.

### Versión para uso personal

El mismo patrón, con prompts genéricos para cualquier proyecto (no solo DBA) e instalador en
`~/.claude/`: [extras/config-personal](../extras/config-personal/README.md).

## Ejercicio 6

1. Entra en `ejemplo-proyecto/` con los plugins cargados y pide:
   *"revisa la migración nueva de migrations/"*. Comprueba con el indicador de la sesión que
   delega en `revisor-migraciones`. Compara con [la solución](soluciones.md#ejercicio-6).
2. Pide *"audita el modelo de datos"* y verifica que usa `auditor-modelo-datos` (haiku).
3. Crea tu propio agente `capacidad` con la skill del ejercicio 5.4, herramientas
   `Read, Bash` y modelo `haiku`.
4. Intenta que `revisor-migraciones` edite un fichero. ¿Qué pasa y por qué?
5. Crea a mano, siguiendo los pasos de 6.4, un agente `capacidad-semanal` en `~/.claude/agents/`
   y otro con el asistente de `/agents`. Compara los dos ficheros resultantes.
6. Con el modo líder activo en `ejemplo-proyecto/`, pide en la misma sesión:
   (a) "¿qué tablas tocan las migraciones?", (b) "escribe la versión corregida de la migración",
   (c) "diseña el particionado por mes de invoices". Anota qué agente usa en cada caso.
7. Clasifica estas tareas por agente (explorador, implementador, especialista o el líder):
   buscar dónde se usa `invoice_lines.discount`; añadir una columna `notes`; investigar un
   deadlock que aparece una vez por semana; renombrar un índice; diseñar la réplica lógica hacia
   el data warehouse; contestar "¿qué versión de PostgreSQL usamos?".
