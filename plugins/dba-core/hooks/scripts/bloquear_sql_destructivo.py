#!/usr/bin/env python3
"""Hook PreToolUse del equipo DBA.

Claude Code envía por stdin un JSON con la herramienta que va a ejecutar.
Si el comando Bash invoca un cliente de base de datos con SQL destructivo,
salimos con código 2: Claude Code bloquea la llamada y le muestra a Claude
el mensaje de stderr para que reconsidere.

Para permitir una excepción puntual, el DBA debe ejecutar el comando él mismo
fuera de Claude (o con el prefijo `!` en la sesión interactiva).
"""
import json
import re
import sys

CLIENTES_BD = re.compile(
    r"\b(psql|pg_restore|mysql|mariadb|sqlplus|sqlcl|sqlcmd|mongosh|clickhouse-client|bq)\b",
    re.IGNORECASE,
)

PATRONES_DESTRUCTIVOS = [
    (r"\bDROP\s+(TABLE|DATABASE|SCHEMA|INDEX|USER|ROLE|TABLESPACE)\b", "DROP"),
    (r"\bTRUNCATE\b", "TRUNCATE"),
    (r"\bDELETE\s+FROM\s+[\w.\"]+\s*(;|$|\")", "DELETE sin WHERE"),
    (r"\bUPDATE\s+[\w.\"]+\s+SET\b(?![^;]*\bWHERE\b)", "UPDATE sin WHERE"),
    (r"\bALTER\s+SYSTEM\b", "ALTER SYSTEM"),
    (r"\bpg_terminate_backend\b|\bKILL\s+\d+", "terminar sesiones"),
    (r"\bGRANT\b|\bREVOKE\b", "cambio de permisos"),
    (r"--clean\b|\bdropdb\b", "restauración destructiva"),
]

# Nombres de host o servicio que se consideran producción.
PRODUCCION = re.compile(r"(prod|prd|produccion|production)", re.IGNORECASE)


def main() -> int:
    try:
        evento = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0  # Si no entendemos la entrada, no bloqueamos.

    if evento.get("tool_name") != "Bash":
        return 0

    comando = evento.get("tool_input", {}).get("command", "")
    if not CLIENTES_BD.search(comando) and "dropdb" not in comando:
        return 0

    for patron, nombre in PATRONES_DESTRUCTIVOS:
        if re.search(patron, comando, re.IGNORECASE):
            entorno = "PRODUCCIÓN" if PRODUCCION.search(comando) else "una base de datos"
            print(
                f"Bloqueado por la política del equipo DBA: '{nombre}' contra {entorno}. "
                "Claude no ejecuta operaciones destructivas. Muestra la sentencia al usuario, "
                "explica su impacto y propón generar una solicitud de cambio con "
                "/dba-core:solicitud-cambio-produccion.",
                file=sys.stderr,
            )
            return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
