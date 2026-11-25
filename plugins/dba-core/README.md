# dba-core

Métodos de trabajo del equipo DBA, independientes del motor.

| Tipo | Nombre | Uso |
|---|---|---|
| Skill | `analisis-plan-ejecucion` | Automática al pegar un plan de ejecución |
| Skill | `revision-migracion` | Automática al revisar DDL / migraciones |
| Skill | `diagnostico-rendimiento` | Automática ante "va lento" |
| Skill | `solicitud-cambio-produccion` | Manual: `/dba-core:solicitud-cambio-produccion <cambio>` |
| Agente | `revisor-migraciones` | Revisión de migraciones, solo lectura de ficheros |
| Agente | `analista-rendimiento` | Diagnóstico de rendimiento, solo consultas de lectura |
| Hook | `PreToolUse` / Bash | Bloquea DROP, TRUNCATE, DELETE/UPDATE sin WHERE, ALTER SYSTEM, GRANT… |

Evals: `claude plugin eval plugins/dba-core`
