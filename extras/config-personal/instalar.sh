#!/usr/bin/env bash
# Instala el patrón líder en tu configuración personal de Claude Code (~/.claude).
# Uso: bash instalar.sh [--force]
#   --force  sobrescribe agentes con el mismo nombre que ya existan.
# Es idempotente: ejecutarlo varias veces no duplica nada.
set -euo pipefail

ORIGEN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESTINO="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
FORCE=0
[[ "${1:-}" == "--force" ]] && FORCE=1

mkdir -p "$DESTINO/agents"

for f in "$ORIGEN"/agents/*.md; do
  nombre="$(basename "$f")"
  if [[ -e "$DESTINO/agents/$nombre" && $FORCE -eq 0 ]]; then
    echo "· Ya existe $DESTINO/agents/$nombre (no se toca; usa --force para sobrescribir)"
  else
    cp "$f" "$DESTINO/agents/$nombre"
    echo "✓ Agente instalado: $DESTINO/agents/$nombre"
  fi
done

CLAUDE_MD="$DESTINO/CLAUDE.md"
touch "$CLAUDE_MD"
if grep -q "<!-- inicio: modo-lider -->" "$CLAUDE_MD"; then
  echo "· El bloque 'Modo líder' ya está en $CLAUDE_MD"
else
  { [[ -s "$CLAUDE_MD" ]] && echo; cat "$ORIGEN/CLAUDE-lider.md"; } >> "$CLAUDE_MD"
  echo "✓ Bloque 'Modo líder' añadido a $CLAUDE_MD"
fi

echo "Listo. Abre una sesión nueva de Claude Code y comprueba con /agents."
