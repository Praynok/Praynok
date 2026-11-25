# Módulo 4 — Memoria del proyecto: CLAUDE.md

> **Objetivo:** que Claude conozca el contexto de cada sistema sin repetírselo.

## 4.1 Dónde se ponen

| Fichero | Alcance |
|---|---|
| `~/.claude/CLAUDE.md` | Tus preferencias personales en todos los proyectos |
| `./CLAUDE.md` (raíz del repo, en git) | Todo el equipo en este proyecto |
| `./CLAUDE.local.md` | Tus notas de este proyecto (no se versiona) |
| `subcarpeta/CLAUDE.md` | Se carga cuando Claude trabaja en esa subcarpeta |
| CLAUDE.md gestionado por la empresa | Todo el mundo, siempre |

Se puede importar otro fichero con `@ruta`, por ejemplo `@docs/topologia.md`.

## 4.2 Qué poner (y qué no) en un CLAUDE.md de base de datos

✅ **Sí**
- Motor, versión, topología (primario/réplicas, RAC, AG).
- Cómo conectarse (variable de entorno y rol), qué entornos están permitidos.
- Herramienta y formato de migraciones.
- Tablas críticas o grandes que requieren cuidado especial.
- Qué skill o agente usar para cada tipo de tarea (el "enrutado" del equipo).

❌ **No**
- Credenciales.
- Procedimientos largos (→ skills).
- Cosas que Claude ya sabe ("PostgreSQL usa MVCC").

Mira el ejemplo: [`ejemplo-proyecto/CLAUDE.md`](../ejemplo-proyecto/CLAUDE.md). Tiene unas 30
líneas: ese es el orden de magnitud correcto.

## 4.3 Repos de infraestructura sin código

Muchos equipos DBA no tienen "un repo de aplicación" sino scripts sueltos. Recomendación:
crea un repo `dba-ops` por plataforma (o uno con subcarpetas por cluster), cada una con su
CLAUDE.md. Arrancar Claude en `dba-ops/clusters/billing-pg/` cargará el contexto correcto.

## Ejercicio 4

1. Ejecuta `/init` en un repo de tu equipo y compara el resultado con la plantilla del ejemplo.
2. Recórtalo a menos de 40 líneas aplicando 4.2.
3. Añade una sección "Forma de trabajar del equipo" que enrute a skills y agentes.
