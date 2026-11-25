# Módulo 8 — MCP y conexión a bases de datos

> **Objetivo:** decidir cómo accede Claude a las bases de datos y hacerlo con control.

## 8.1 Dos formas de acceder

| | Cliente de línea de comandos (`psql`, `sqlplus`…) vía Bash | Servidor MCP de base de datos |
|---|---|---|
| Instalación | Ya lo tenéis | Hay que elegir, revisar y mantener un servidor |
| Control | Permisos Bash + hook + rol | Permisos por herramienta MCP + rol |
| Salida | Texto; controlable con flags (`-A -F '|'`) | Estructurada |
| Recomendado para | **Empezar**; equipos DBA en bastiones | Integraciones más ricas, entornos sin shell |

Recomendación del curso: **empezad con el cliente nativo** (lo que usan las skills de este
repo) y añadid MCP cuando haya una necesidad clara. Los MCP más útiles para DBAs a menudo no
son de bases de datos sino de **ticketing** (Jira/ServiceNow), **monitorización**
(Grafana, Datadog) y **documentación** (Confluence).

## 8.2 Añadir un servidor MCP

```bash
# Ámbito proyecto: se guarda en .mcp.json y se comparte por git
claude mcp add --scope project postgres-staging -- npx -y <paquete> "$PG_RO_URL"

# Ámbito usuario: solo tú, en todos tus proyectos
claude mcp add --scope user grafana --transport http https://grafana.interno/mcp

claude mcp list
/mcp           # dentro de la sesión: estado y autenticación
```

`.mcp.json` admite variables de entorno, así la credencial no se versiona:

```json
{
  "mcpServers": {
    "postgres-staging": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "<paquete-mcp-postgres-aprobado-por-seguridad>", "${PG_RO_URL}"]
    }
  }
}
```

> Elige el paquete con seguridad: un servidor MCP es código que se ejecuta con tus credenciales.
> Usa solo servidores revisados y fija versiones. Claude Code pide aprobación la primera vez
> que se usa un `.mcp.json` de proyecto.

## 8.3 Permisos sobre herramientas MCP

```json
{
  "permissions": {
    "allow": ["mcp__postgres-staging__query"],
    "deny":  ["mcp__postgres-prod__*"]
  }
}
```

Y siempre: el servidor se conecta con el **rol de solo lectura** del módulo 3.

## 8.4 MCP dentro de un plugin

Un plugin puede traer su `.mcp.json` en la raíz; al habilitar el plugin, el servidor queda
disponible. Útil para un plugin `dba-observabilidad` que conecte con vuestra monitorización.

## 8.5 Datos sensibles

- Preferid **catálogo y estadísticas** sobre datos de negocio: para diagnosticar casi nunca
  hace falta leer filas.
- Si hay que ver datos, usad entornos enmascarados o vistas que excluyan columnas PII.
- `statement_timeout` y `LIMIT` evitan que una consulta exploratoria degrade el servicio.

## Ejercicio 8

1. Decide para tu equipo: ¿cliente nativo, MCP o ambos? Justifícalo en 3 líneas.
2. Configura un MCP de un sistema no-BD que uséis (ticketing o monitorización) en ámbito usuario.
3. Escribe las reglas `allow`/`deny` para sus herramientas.
