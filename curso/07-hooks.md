# Módulo 7 — Hooks: guardarraíles automáticos

> **Objetivo:** reglas que se cumplen **siempre**, decida lo que decida el modelo.

## 7.1 Qué es un hook

Un comando de shell que Claude Code (no el modelo) ejecuta en un evento. Si las skills son
"lo que Claude debería hacer", los hooks son "lo que va a pasar sí o sí".

| Evento | Cuándo | Uso DBA típico |
|---|---|---|
| `PreToolUse` | Antes de usar una herramienta | **Bloquear SQL destructivo**, impedir conexión a prod |
| `PostToolUse` | Después de usarla | Auditar cada comando `psql` ejecutado; lint de ficheros SQL editados |
| `UserPromptSubmit` | Al enviar un prompt | Avisar si alguien pega datos personales |
| `SessionStart` | Al iniciar sesión | Mostrar el entorno al que apunta `PG_RO_URL` |
| `Stop` / `SubagentStop` | Al terminar | Notificaciones |

## 7.2 Contrato de un hook de comando

- Recibe por **stdin** un JSON con, entre otros, `tool_name` y `tool_input`
  (para Bash: `tool_input.command`).
- **Código de salida 0** → continuar.
- **Código de salida 2** → bloquear; lo que escribas en **stderr** se le muestra a Claude
  para que corrija su plan.
- Otro código → error no bloqueante (se muestra al usuario).

## 7.3 El hook del equipo: bloquear SQL destructivo

Script: [`plugins/dba-core/hooks/scripts/bloquear_sql_destructivo.py`](../plugins/dba-core/hooks/scripts/bloquear_sql_destructivo.py).
Si el comando Bash invoca un cliente de BD (`psql`, `sqlplus`, `sqlcmd`, `mysql`, `mongosh`…)
y contiene `DROP`, `TRUNCATE`, `DELETE`/`UPDATE` sin `WHERE`, `ALTER SYSTEM`,
`pg_terminate_backend`, `GRANT`/`REVOKE`…, sale con código 2.

Registro en el plugin ([`hooks/hooks.json`](../plugins/dba-core/hooks/hooks.json)):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/bloquear_sql_destructivo.py\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

`${CLAUDE_PLUGIN_ROOT}` apunta a la carpeta del plugin instalado. Fuera de un plugin, el mismo
bloque va dentro de `"hooks"` en `.claude/settings.json` (usa `$CLAUDE_PROJECT_DIR` para rutas).

### Probarlo sin Claude

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"psql -c \"TRUNCATE payments\""}}' \
  | python3 plugins/dba-core/hooks/scripts/bloquear_sql_destructivo.py; echo "salida=$?"
# → mensaje en stderr y salida=2

echo '{"tool_name":"Bash","tool_input":{"command":"psql -c \"SELECT 1\""}}' \
  | python3 plugins/dba-core/hooks/scripts/bloquear_sql_destructivo.py; echo "salida=$?"
# → salida=0
```

### Limitaciones (sé honesto con el equipo)

Un hook basado en expresiones regulares **no es una barrera de seguridad completa**: SQL en
un fichero (`psql -f script.sql`), variables de shell o codificaciones raras pueden escaparse.
Por eso el orden de defensa es:

1. **Rol de base de datos de solo lectura** (barrera real).
2. **Permisos** `deny` para hosts de producción.
3. **Hook** como red para errores honestos del modelo.
4. **Prompt** del agente con los límites.

Mejora posible: si el comando usa `-f fichero.sql`, que el hook lea el fichero y aplique
los mismos patrones (ejercicio 7.2).

## 7.4 Hook de auditoría (PostToolUse)

Registrar cada comando de BD ejecutado por Claude, para trazabilidad:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{ts: now|todate, sesion: .session_id, cmd: .tool_input.command}' >> \"$HOME/.claude/auditoria-bd.jsonl\""
          }
        ]
      }
    ]
  }
}
```

## 7.5 Hooks gestionados

En `managed-settings.json`, `"allowManagedHooksOnly": true` hace que solo se ejecuten los
hooks definidos por la organización (y los de plugins habilitados por ella), para que nadie
los desactive localmente.

## Ejercicio 7

1. Ejecuta las pruebas de 7.3 y añade dos casos que el hook no detecte. ¿Cómo los cubrirías?
2. Amplía el script para inspeccionar ficheros pasados con `-f` / `@script.sql`.
3. Añade el hook de auditoría de 7.4 a tu `~/.claude/settings.json` y revisa `/hooks`.
4. En una sesión con el plugin cargado, pide a Claude *"vacía la tabla payments en dev"* y
   observa cómo reacciona al bloqueo.
