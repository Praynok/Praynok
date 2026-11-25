---
name: analisis-plan-ejecucion
description: Método del equipo DBA para analizar planes de ejecución (EXPLAIN / EXPLAIN ANALYZE, planes de Oracle, SQL Server o MySQL). Úsala cuando el usuario pegue un plan de ejecución, pregunte por qué una consulta es lenta, o pida recomendar índices o reescribir una consulta.
---

# Análisis de plan de ejecución (método del equipo)

Sigue SIEMPRE estos pasos en orden. No propongas índices antes del paso 4.

## 1. Contexto mínimo

Antes de opinar, confirma (pregunta si falta):

- Motor y versión (PostgreSQL 16, Oracle 19c, SQL Server 2022…).
- ¿Es `EXPLAIN` (estimado) o `EXPLAIN ANALYZE` / plan real? Si es estimado, dilo en el informe:
  las conclusiones sobre tiempos son hipótesis.
- Tiempo actual y objetivo (SLA) de la consulta, y frecuencia de ejecución.

## 2. Localiza el nodo caro

- Recorre el plan de dentro hacia fuera. Identifica el nodo con mayor tiempo **propio**
  (tiempo del nodo menos el de sus hijos), no el acumulado.
- En planes reales, multiplica siempre por `loops`.

## 3. Compara estimado frente a real

- Calcula el factor de error de cardinalidad: `filas_reales / filas_estimadas`.
- Un factor > 10x o < 0,1x es un **hallazgo por sí mismo**: apunta a estadísticas
  obsoletas, correlación entre columnas o parámetros sniffados.
  Recomienda primero actualizar estadísticas (`ANALYZE`, `DBMS_STATS`, `UPDATE STATISTICS`)
  antes que crear índices.

## 4. Patrones conocidos

Revisa la tabla de [patrones.md](patrones.md) y señala cada patrón que aparezca.

## 5. Recomendación

Ordena las propuestas por **riesgo ascendente**:

1. Estadísticas / configuración de sesión.
2. Reescritura de la consulta.
3. Índice nuevo (indica columnas, orden, si es parcial/filtrado, y el coste en escrituras).
4. Cambios de esquema o de parámetros de instancia (requieren solicitud de cambio:
   usa la skill `solicitud-cambio-produccion`).

Para cada índice propuesto, incluye la sentencia de creación **online**
(`CREATE INDEX CONCURRENTLY`, `ONLINE = ON`, `ONLINE` en Oracle) y la de rollback.

## Formato de salida

```
## Resumen
<una frase: qué es lento y por qué>

## Nodo crítico
<nodo, tiempo propio, filas estimadas vs reales>

## Hallazgos
| # | Patrón | Evidencia en el plan | Impacto |

## Recomendaciones (de menor a mayor riesgo)
1. ...

## Verificación
<cómo comprobar la mejora: qué ejecutar y qué métrica mirar>
```
