# Módulo 12 — Gobernanza y plan de adopción

> **Objetivo:** desplegar al equipo de forma ordenada y mantener las skills vivas.

## 12.1 Roles

| Rol | Responsabilidad |
|---|---|
| **Owner del marketplace** (1 persona) | Revisa PRs al repo de plugins, publica versiones, mantiene settings gestionados |
| **Owner de skill** (cada método tiene uno) | Mantiene su skill y sus evals; es quien mejor conoce ese método |
| **DBA usuario** | Usa, reporta fallos, propone mejoras vía PR o issue |
| **Seguridad** | Aprueba roles de BD, servidores MCP y política de datos |

Añade un `CODEOWNERS` en el repo del marketplace:

```
/plugins/dba-core/skills/revision-migracion/   @ana
/plugins/dba-postgres/                          @equipo-postgres
/plugins/*/hooks/                               @owner-marketplace @seguridad
```

## 12.2 Reglas del repo de plugins

1. Toda skill nueva llega con al menos **un caso de eval**.
2. Cambios en hooks o en `tools` de un agente requieren **dos aprobaciones**.
3. Nada de credenciales, hostnames de producción ni datos reales en skills o evals.
4. Las skills describen el método **actual** del equipo: si el método cambia, cambia la skill
   (la skill es ahora la documentación oficial del método).
5. `claude plugin validate` y `claude plugin eval --threshold 0.8` en la CI del propio repo.

## 12.3 Plan de adopción en 4 semanas

| Semana | Objetivo | Entregables |
|---|---|---|
| 1 — **Piloto** | 2–3 DBAs, solo dev/staging, modo plan | Rol `claude_ro` creado; inventario de métodos (ej. 1); CLAUDE.md de 2 sistemas |
| 2 — **Primeras skills** | Convertir los 3 métodos más usados | Plugin `dba-core` v0.1 con 3 skills + hook; evals básicas |
| 3 — **Agentes y distribución** | Roles y marketplace | 2–3 agentes; marketplace en git; `enabledPlugins` en los repos de los sistemas |
| 4 — **Equipo completo** | Todo el equipo + CI | Settings gestionados; revisión de migraciones en PR; sesión de formación con este curso |

## 12.4 Métricas para saber si funciona

- Tiempo medio de revisión de una migración (antes / después).
- % de migraciones con hallazgos detectados por el agente que el DBA confirmó.
- Nº de bloqueos del hook (debería tender a 0; si sube, revisar skills/prompts).
- Nº de PRs al marketplace por mes (señal de que el equipo se lo ha apropiado).
- Puntuación media de evals por versión.

## 12.5 Errores frecuentes

| Error | Consecuencia | Solución |
|---|---|---|
| CLAUDE.md gigante con todos los procedimientos | Contexto saturado, instrucciones ignoradas | Mover procedimientos a skills |
| Descripciones de skill vagas | Las skills no se activan | Describir *cuándo* con el vocabulario del DBA |
| Agente "todo en uno" con todas las herramientas | Riesgo y resultados mediocres | Un rol por agente, mínimo privilegio |
| Confiar solo en el hook | Falsa sensación de seguridad | Rol de solo lectura en la BD |
| Copiar skills entre repos | Versiones divergentes | Plugin + marketplace |
| Sin evals | Regresiones silenciosas | Un caso por skill como mínimo |

## Proyecto final

Con todo lo visto, entrega en tu marketplace:

1. Un plugin `dba-<tu-motor>` con **3 skills** basadas en métodos reales de tu equipo
   (al menos una con ficheros `.sql` y una de invocación manual).
2. **2 agentes** con skills precargadas y herramientas mínimas.
3. Un hook adaptado a tu motor.
4. Un caso de eval por skill, superando `--threshold 0.8`.
5. Un repo de sistema con CLAUDE.md, `settings.json` que habilite el plugin y la revisión en CI.
