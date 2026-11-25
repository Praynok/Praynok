# Config personal: patrón líder (Haiku lee, Sonnet escribe, Fable para lo difícil)

Versión de uso general del patrón explicado en el
[módulo 6.6 del curso](../../curso/06-subagentes.md#66-patrón-líder-un-modelo-por-rol),
para **todos tus proyectos**, no solo los de bases de datos.

| Fichero | Va a | Qué es |
|---|---|---|
| `agents/explorador.md` | `~/.claude/agents/` | Lee y busca. Haiku, solo lectura |
| `agents/implementador.md` | `~/.claude/agents/` | Escribe código y ejecuta tests. Sonnet |
| `agents/especialista.md` | `~/.claude/agents/` | Problemas difíciles. Fable, el más caro |
| `CLAUDE-lider.md` | se añade a `~/.claude/CLAUDE.md` | Instrucciones para que la sesión principal actúe de líder |

## Instalar

En tu máquina (no en una sesión web: allí `~/.claude` se pierde al cerrar):

```bash
bash extras/config-personal/instalar.sh          # no pisa agentes que ya tengas
bash extras/config-personal/instalar.sh --force  # sobrescribe los de mismo nombre
```

El script copia los agentes y añade el bloque del líder a `~/.claude/CLAUDE.md` una sola vez
(lo delimitan las marcas `<!-- inicio: modo-lider -->` y `<!-- fin: modo-lider -->`; para
desinstalarlo, borra ese bloque y los tres ficheros).

## Notas

- Si un proyecto tiene agentes con el mismo nombre en su `.claude/agents/`, **ganan los del
  proyecto** (por ejemplo, los del `ejemplo-proyecto/` de este curso, adaptados a DBA).
- Si tu cuenta no admite el alias `model: fable`, usa el ID completo `claude-fable-5-2`, o
  `opus` si no tienes acceso a Fable.
- Para usar el patrón solo en una sesión, sin instalarlo, pega el contenido de
  `CLAUDE-lider.md` al empezar.
