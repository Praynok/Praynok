# Módulo 10 — Evals: probar que las skills funcionan

> **Objetivo:** que un cambio en una skill no rompa en silencio el método del equipo.

## 10.1 Qué se prueba

1. **Activación**: ante un prompt realista, ¿se carga la skill correcta?
2. **Calidad**: ¿la respuesta cumple el método (detecta lo que debe, respeta el formato)?
3. **Mejora frente a no tener la skill**: el runner ejecuta también una variante sin el
   plugin y reporta la diferencia de puntuación.

## 10.2 Estructura

```
plugins/dba-core/evals/
├── plan-seq-scan/
│   ├── prompt.md              ← el caso: frontmatter (max_turns, allowed_tools) + prompt
│   └── graders/
│       └── criterios.md       ← cómo se puntúa (type: llm = lo juzga un modelo)
└── migracion-insegura/
    ├── prompt.md
    └── graders/criterios.md
```

Caso de ejemplo ([`evals/plan-seq-scan/prompt.md`](../plugins/dba-core/evals/plan-seq-scan/prompt.md)):

```markdown
---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Esta consulta tarda 4 segundos en PostgreSQL 16 y debería tardar menos de 50 ms. ¿Qué pasa?
(plan con Seq Scan sobre lower(email)...)
```

Criterio ([`graders/criterios.md`](../plugins/dba-core/evals/plan-seq-scan/graders/criterios.md)):

```markdown
---
type: llm
weight: 2
---
Una respuesta correcta:
- Detecta que el predicado lower(email) no es sargable.
- Señala el error de cardinalidad (25000 estimadas frente a 3 reales).
- Propone índice por expresión con CREATE INDEX CONCURRENTLY y su rollback.
...
```

## 10.3 Ejecutar

```bash
claude plugin eval ./plugins/dba-core                     # todos los casos, 3 ejecuciones cada uno
claude plugin eval ./plugins/dba-core --case 'plan-*'     # filtrar
claude plugin eval ./plugins/dba-core --runs 5 --threshold 0.8   # sale con 1 si algún caso < 0,8
claude plugin eval init --bare nuevo-caso                 # plantilla vacía (dentro del plugin)
claude plugin eval init                                   # asistente que diseña casos y criterios
```

El resultado incluye un informe HTML con puntuaciones, prompts y veredictos de cada criterio.

## 10.4 De dónde salen buenos casos

- **Incidencias reales** anonimizadas (el mejor material: cada post-mortem → un caso).
- **Errores que ya cometió Claude** con vuestras skills: conviértelos en caso antes de corregir la skill.
- **Casos frontera**: una migración segura que no debe rechazarse (evita skills paranoicas).

## Ejercicio 10

1. Ejecuta las evals de `dba-core` y revisa el informe.
2. Añade el caso "migración segura" (CREATE INDEX CONCURRENTLY con lock_timeout) cuyo
   criterio sea que el veredicto **sí** sea APROBADA.
3. Empeora a propósito la descripción de `analisis-plan-ejecucion` y observa cómo baja la puntuación.
