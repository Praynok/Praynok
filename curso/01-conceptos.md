# Módulo 1 — Conceptos: las piezas de Claude Code

> **Objetivo:** saber qué pieza de Claude Code corresponde a cada cosa que tu equipo ya hace.

## 1.1 Qué es Claude Code

Claude Code es un agente que trabaja en tu terminal: lee ficheros, ejecuta comandos
(`psql`, `sqlplus`, `git`…), edita código y razona en bucle hasta completar una tarea.
Lo que lo hace útil para un equipo no es el modelo en sí, sino que **se puede configurar
con el conocimiento y las reglas del equipo** y compartir esa configuración.

## 1.2 Las piezas

| Pieza | Qué es | Dónde vive | Cuándo se carga | Analogía DBA |
|---|---|---|---|---|
| **CLAUDE.md** | Instrucciones en texto libre | Raíz del repo, `~/.claude/` | Siempre, al iniciar sesión | La wiki del sistema |
| **Skill** | Carpeta con `SKILL.md` + ficheros de apoyo (SQL, plantillas, scripts) | `.claude/skills/`, `~/.claude/skills/`, plugins | Solo la descripción al inicio; el contenido cuando hace falta | Un runbook o checklist |
| **Subagente** | Asistente especializado con su propio prompt, herramientas, modelo y skills | `.claude/agents/`, `~/.claude/agents/`, plugins | Cuando Claude delega o se lo pides | Un compañero especialista al que le pasas un ticket |
| **Hook** | Script que se ejecuta en eventos (antes/después de usar una herramienta…) | `settings.json`, plugins | Siempre, de forma determinista | Un trigger o una política de auditoría |
| **Permisos** | Reglas allow / ask / deny por herramienta | `settings.json` | Siempre | Los GRANT de Claude |
| **MCP server** | Conector a sistemas externos (BD, ticketing, monitorización) | `.mcp.json`, settings | Al iniciar sesión | Un DB link / conector |
| **Plugin** | Paquete que agrupa skills + agentes + hooks + MCP | Un marketplace (repo git) | Al habilitarlo | Un paquete RPM de configuración |
| **Marketplace** | Catálogo de plugins | Repo git con `.claude-plugin/marketplace.json` | Al registrarlo | El repositorio YUM interno |

## 1.3 Skills frente a CLAUDE.md frente a subagentes

La pregunta que más se repite. Regla práctica:

- **CLAUDE.md**: hechos que Claude necesita *siempre* en ese proyecto
  ("esto es PostgreSQL 16", "conéctate con `claude_ro`", "las migraciones son Flyway").
  Corto: cada línea consume contexto en cada sesión.
- **Skill**: un *procedimiento* que se usa a veces ("cómo analizamos un plan",
  "checklist de migraciones"). Solo ocupa ~100 tokens (su descripción) hasta que se usa.
- **Subagente**: un *rol* que hace un trabajo completo en su propio contexto y devuelve un
  resultado ("revisa estas 12 migraciones"). Útil para aislar trabajo largo, restringir
  herramientas, o usar otro modelo.

> Las skills son el **qué sabemos hacer**. Los subagentes son el **quién lo hace** y con
> qué permisos. Un subagente puede llevar varias skills precargadas.

> ### ⚠️ Error frecuente: "un agente es un conjunto de skills"
> No exactamente. Un **agente** es un modelo que razona, un bucle (observa → decide → actúa →
> comprueba → repite), unas **herramientas** para actuar (leer ficheros, ejecutar `psql`…) y unas
> instrucciones. Una **skill** es un manual: le dice al agente *cómo* hacer algo, pero por sí
> sola no ejecuta nada.
>
> Analogía: el agente es el DBA (criterio, manos y forma de trabajar); las skills son sus
> runbooks. Un agente sin skills sigue siendo un agente; un montón de skills sin agente es
> solo documentación.
>
> Lo que sí es cierto: lo que distingue a un agente **especializado** (el revisor, el de
> guardia) de uno genérico suele ser su combinación de skills, herramientas, modelo e
> instrucciones. Eso es exactamente lo que se configura en el módulo 6.

## 1.4 Divulgación progresiva (por qué las skills escalan)

Al iniciar sesión Claude solo ve el `name` y la `description` de cada skill. Cuando una
tarea encaja con una descripción, carga el `SKILL.md` completo; y solo si el SKILL.md lo
indica, abre los ficheros de apoyo (`patrones.md`, `sql/*.sql`). Por eso un equipo puede tener
decenas de skills sin saturar el contexto. Consecuencia directa: **la descripción es lo
más importante de una skill** (módulo 5).

Puedes medirlo: `claude --plugin-dir plugins/dba-core plugin details dba-core` muestra el
coste "always-on" (las descripciones) y "on-invoke" de cada componente.

## 1.5 Mapa del equipo DBA

```
             Métodos del equipo (hoy en wikis, Excel, cabezas)
                                │
         ┌──────────────────────┼─────────────────────────┐
         ▼                      ▼                         ▼
  Hechos por proyecto     Procedimientos            Reglas que NO se pueden
  (motor, conexión,       (checklists, runbooks,    saltar (no DROP, no prod)
   convenciones)           consultas de catálogo)
         │                      │                         │
     CLAUDE.md               SKILLS                 PERMISOS + HOOKS
                                │
                         agrupadas en roles
                                │
                           SUBAGENTES
                                │
             todo empaquetado y versionado en PLUGINS
                                │
                    publicados en un MARKETPLACE
```

## Ejercicio 1

Haz inventario de 10 "métodos" de tu equipo (un checklist, una consulta que siempre
lanzáis, una plantilla…). Para cada uno decide: ¿CLAUDE.md, skill, subagente, hook o
permiso? Guarda la tabla: la usarás en los módulos 5 y 6.
