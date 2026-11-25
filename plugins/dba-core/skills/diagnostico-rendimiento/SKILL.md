---
name: diagnostico-rendimiento
description: Runbook de triage del equipo DBA para incidencias de rendimiento de base de datos ("la base de datos va lenta", picos de CPU, latencia alta, timeouts, crecimiento de conexiones). Úsala al empezar cualquier investigación de rendimiento, antes de mirar consultas concretas.
---

# Diagnóstico de rendimiento (triage)

Objetivo: pasar de "va lento" a una hipótesis comprobable en menos de 15 minutos.
Trabaja **de lo general a lo particular** y no cambies nada en la instancia durante el triage.

## Paso 1 — Acota el síntoma
Pregunta o deduce: ¿desde cuándo?, ¿todas las aplicaciones o una?, ¿todas las consultas o
algunas?, ¿hubo despliegue, cambio de parámetros, carga batch o failover reciente?

## Paso 2 — Recursos del servidor
CPU, memoria, I/O (latencia y IOPS), red. Clasifica: **CPU-bound**, **I/O-bound**,
**esperas por bloqueos** o **saturación de conexiones**.

## Paso 3 — Esperas
Consulta los eventos de espera del motor (`pg_stat_activity.wait_event`, AWR/ASH,
`sys.dm_os_wait_stats`, `performance_schema`). La espera dominante decide el siguiente paso:

| Espera dominante | Siguiente paso |
|---|---|
| Bloqueos (Lock) | Skill de bloqueos del motor (p. ej. `pg-bloqueos`) |
| I/O | Top consultas por lecturas físicas → `analisis-plan-ejecucion` |
| CPU | Top consultas por tiempo de CPU → `analisis-plan-ejecucion` |
| Conexiones / pool | Revisar pool de la aplicación y conexiones `idle in transaction` |

## Paso 4 — Top consultas
Obtén el top 10 por tiempo total (no por tiempo medio) desde `pg_stat_statements`,
Query Store, AWR o `events_statements_summary_by_digest`.

## Paso 5 — Informe
```
Síntoma: ...
Clasificación: CPU / I/O / bloqueos / conexiones
Evidencia: (métricas y consultas con valores)
Hipótesis principal: ...
Siguiente acción recomendada (sin ejecutar): ...
```

**Nunca** mates sesiones, reinicies servicios ni cambies parámetros: propónlo y deja que
el DBA de guardia decida.
