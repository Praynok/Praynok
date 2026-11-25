---
name: solicitud-cambio-produccion
description: Genera una solicitud de cambio (RFC) para producción con el formato del equipo DBA a partir de una descripción del cambio.
argument-hint: <descripción breve del cambio>
disable-model-invocation: true
---

# Solicitud de cambio a producción

Redacta una solicitud de cambio para: **$ARGUMENTS**

Si falta información obligatoria, pregúntala antes de redactar. No inventes ventanas,
nombres de servidor ni aprobadores.

## Plantilla obligatoria

```markdown
# RFC: <título>

| Campo | Valor |
|---|---|
| Entorno | producción / <instancia> |
| Motor y versión | |
| Ventana propuesta | |
| Duración estimada | |
| Impacto en servicio | ninguno / degradación / corte (minutos) |
| Riesgo | bajo / medio / alto (justificar) |
| Responsable de ejecución | |
| Aprobador | |

## Motivo

## Pasos de ejecución
1. Verificar backup reciente: <cómo>
2. ...

## Verificación posterior
- <consulta o métrica> → valor esperado

## Rollback
- Criterio para activar el rollback:
- Pasos:

## Comunicación
- A quién se avisa antes y después
```

Clasificación de riesgo del equipo:
- **Bajo**: online, reversible, sin bloqueos exclusivos.
- **Medio**: reversible pero con bloqueos breves o carga notable.
- **Alto**: irreversible, requiere corte o afecta a más de una aplicación.
