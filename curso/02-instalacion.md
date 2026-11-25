# Módulo 2 — Instalación y primer arranque

> **Objetivo:** tener Claude Code instalado, autenticado con la cuenta del equipo y
> conocer los comandos básicos.

## 2.1 Instalación

```bash
# macOS / Linux / WSL (instalador nativo, se actualiza solo)
curl -fsSL https://claude.ai/install.sh | bash

# Windows (PowerShell)
irm https://claude.ai/install.ps1 | iex

# Alternativa con npm (Node 18+)
npm install -g @anthropic-ai/claude-code

claude --version
claude doctor        # diagnóstico de la instalación
```

En los bastiones / servidores de salto donde trabajéis con las bases de datos, instaladlo
también allí: Claude ejecutará `psql`/`sqlplus` desde donde se arranque.

## 2.2 Autenticación para un equipo

| Opción | Para quién | Notas |
|---|---|---|
| Plan **Claude Team / Enterprise** | Lo habitual en equipos | Gestión de usuarios centralizada, SSO, settings gestionados desde la consola de administración |
| **Claude Console** (API) | Equipos que pagan por uso | Facturación por tokens, claves por usuario o por proyecto |
| **Amazon Bedrock / Google Vertex AI / Microsoft Foundry** | Cuando los datos no deben salir de vuestro proveedor cloud | Se configura con variables de entorno (p. ej. `CLAUDE_CODE_USE_BEDROCK=1`) |

```bash
claude            # la primera vez abre el login en el navegador
/login            # cambiar de cuenta dentro de una sesión
/status           # ver cuenta, modelo y settings activos
```

> **Datos sensibles**: antes de desplegar, revisa con seguridad la política de retención de
> datos de vuestro plan. Lo que Claude lee (resultados de consultas incluidos) viaja al
> modelo. Este es el principal motivo para usar roles de solo lectura y entornos no
> productivos (módulos 3 y 8).

## 2.3 Comandos esenciales

| Comando | Para qué |
|---|---|
| `claude` | Sesión interactiva en el directorio actual |
| `claude -c` | Continuar la última conversación |
| `claude -p "pregunta"` | Modo no interactivo (scripts, CI) |
| `/init` | Genera un CLAUDE.md inicial analizando el repo |
| `/memory` | Editar los CLAUDE.md |
| `/permissions` | Ver y editar reglas de permisos |
| `/agents` | Gestionar subagentes |
| `/plugin` | Gestionar plugins y marketplaces |
| `/hooks` | Ver hooks configurados |
| `/mcp` | Estado de los servidores MCP |
| `/context` | Qué está ocupando el contexto |
| `/model` | Cambiar de modelo |
| `!comando` | Ejecutar un comando de shell tú mismo, sin pasar por Claude |
| `Shift+Tab` | Alternar modos de permisos (normal / aceptar ediciones / plan) |
| `Esc` | Interrumpir a Claude |

**Modo plan** (`Shift+Tab` hasta "plan mode"): Claude investiga y propone, pero no
modifica nada. Es el modo recomendado para empezar cualquier tarea sobre una base de datos.

## 2.4 Dónde usar Claude Code: CLI, IDE, escritorio o web

Claude Code es **un único producto con varias formas de usarlo**. El agente es el mismo
(skills, agentes, hooks, MCP…); lo que cambia es **dónde se ejecuta** y, por tanto, **a qué llega**.

| Superficie | Dónde se ejecuta | ¿Llega a vuestras BD internas? | Uso recomendado en el equipo DBA |
|---|---|---|---|
| **CLI** (`claude` en la terminal) | En tu máquina o en el bastión | ✅ Sí, con tu red, VPN, `psql` y credenciales | **Todo lo que toque una base de datos.** Es también la única para scripts y CI (`claude -p`) |
| **Extensión de IDE** (VS Code, JetBrains) | En tu máquina | ✅ Igual que la CLI | Escribir migraciones viendo los cambios en el editor |
| **App de escritorio** (Mac/Windows) | En tu máquina | ✅ Igual que la CLI | Quien prefiera interfaz gráfica |
| **Web / móvil** (claude.ai/code) | En un contenedor temporal en la nube que clona el repo de GitHub | ❌ No, salvo que conectes tu máquina con Remote Control | Mantener el repo de skills y plugins, revisar PRs, tareas largas que no necesitan la BD |

Consecuencias prácticas:
- **Instalad la CLI en los bastiones**: es desde donde Claude puede lanzar `psql`/`sqlplus`
  con el rol de solo lectura.
- **La web sirve para trabajar *sobre* el marketplace** (escribir una skill, preparar un PR),
  no para diagnosticar una instancia. Lo que no se suba con commit y push se pierde al cerrar
  la sesión.
- Las funciones nuevas a veces llegan antes a una superficie que a otra; ante la duda,
  consulta la documentación oficial.

## Ejercicio 2

1. Instala Claude Code y ejecuta `claude doctor`.
2. Clona este repo, entra en `ejemplo-proyecto/` y arranca con:
   `claude --plugin-dir ../plugins/dba-core --plugin-dir ../plugins/dba-postgres`
3. Ejecuta `/agents` y `/hooks` y localiza lo que aportan los plugins.
4. Pregunta: *"¿qué skills tienes disponibles y cuándo usarías cada una?"*
