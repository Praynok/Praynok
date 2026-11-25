# Módulo 11 — Automatización: modo headless y CI

> **Objetivo:** que las skills y agentes del equipo trabajen también sin nadie delante:
> revisión de migraciones en cada PR, informes programados.

## 11.1 Modo headless

```bash
claude -p "Revisa las migraciones nuevas de migrations/ con el agente revisor-migraciones" \
  --allowedTools "Read,Grep,Glob,Agent" \
  --output-format json \
  --max-turns 20
```

| Flag | Uso |
|---|---|
| `-p` / `--print` | Ejecuta, imprime el resultado y termina |
| `--output-format text\|json\|stream-json` | `json` para procesarlo con `jq` |
| `--allowedTools` / `--disallowedTools` | Permisos para esta ejecución (no hay nadie para aprobar) |
| `--permission-mode plan` | Solo análisis |
| `--plugin-dir` | Cargar plugins desde el checkout (ideal en CI) |
| `--append-system-prompt` | Instrucciones extra para esta ejecución |
| `--agents '<json>'` | Definir agentes al vuelo |

## 11.2 Revisión de migraciones en cada PR (GitHub Actions)

```yaml
# .github/workflows/revision-migraciones.yml (en el repo del proyecto)
name: Revisión DBA de migraciones
on:
  pull_request:
    paths: ["migrations/**"]

permissions:
  contents: read
  pull-requests: write

jobs:
  revisar:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/checkout@v4
        with:
          repository: tu-org/claude-dba          # el marketplace del equipo
          path: .claude-dba
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Usa el agente revisor-migraciones para revisar los ficheros de migrations/
            modificados en este PR. Publica el informe como comentario del PR.
            Si el veredicto es RECHAZADA, indícalo al principio en negrita.
          claude_args: >-
            --plugin-dir .claude-dba/plugins/dba-core
            --allowedTools Read,Grep,Glob,Agent
```

En GitLab CI, Jenkins, etc.: instala Claude Code en la imagen y usa `claude -p` con
`ANTHROPIC_API_KEY` como secreto.

## 11.3 Puerta de calidad con salida estructurada

```bash
resultado=$(claude -p "Revisa migrations/V2026*.sql con el agente revisor-migraciones. \
  Termina con una línea exacta: VEREDICTO=<APROBADA|APROBADA CON CAMBIOS|RECHAZADA>" \
  --plugin-dir ./.claude-dba/plugins/dba-core \
  --allowedTools "Read,Grep,Glob,Agent" --output-format json | jq -r '.result')

echo "$resultado"
grep -q "VEREDICTO=RECHAZADA" <<< "$resultado" && exit 1 || exit 0
```

> La revisión automática **asiste** al DBA, no lo sustituye: configura la rama para que el PR
> requiera además la aprobación de un miembro del equipo DBA (CODEOWNERS sobre `migrations/`).

## 11.4 Informes programados

Un cron en el bastión que ejecute cada lunes el chequeo de salud contra staging:

```bash
0 7 * * 1  cd /opt/dba-ops/billing && PG_RO_URL=... claude -p \
  "Ejecuta la skill pg-salud y genera el informe" \
  --allowedTools "Read,Bash(psql:*),Skill" --output-format text > informes/salud-$(date +\%F).md
```

## Ejercicio 11

1. Ejecuta la revisión headless de 11.1 sobre `ejemplo-proyecto/migrations/` con `--plugin-dir`.
2. Implementa la puerta de 11.3 y comprueba que la migración de ejemplo da `exit 1`.
3. Adapta el workflow de 11.2 a vuestro sistema de CI.
