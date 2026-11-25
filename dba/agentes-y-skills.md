# ¿Es un agente un conjunto de skills?

No exactamente. Las skills son una pieza que el agente usa, no lo que lo define.

## Qué es un agente

1. **Un modelo** que razona y decide (p. ej. Claude).
2. **Un bucle**: observa → decide → actúa → mira el resultado → repite, hasta terminar la tarea.
3. **Herramientas** para actuar sobre el mundo: leer y editar archivos, ejecutar comandos, buscar en la web, llamar a APIs (MCP)...
4. **Contexto e instrucciones**: system prompt, CLAUDE.md, la conversación y la memoria.

## Qué es una skill

Un paquete de conocimiento o procedimiento (instrucciones, a veces con scripts o plantillas) que el agente **carga cuando lo necesita**. Por ejemplo, "cómo crear un .docx bien hecho" o "cómo hacer un code review según nuestras reglas". No ejecuta nada por sí misma: le dice al agente *cómo* hacer algo.

## Analogía

- El **agente** es un profesional: tiene criterio (modelo), manos y equipo (herramientas) y una forma de trabajar (bucle).
- Las **skills** son sus manuales o recetas: le hacen mejor en tareas concretas, pero sin el profesional no hacen nada.

Un agente sin skills sigue siendo un agente. Un montón de skills sin modelo ni bucle es solo documentación.

## Dónde tiene algo de razón la idea

Lo que distingue a un agente especializado de uno genérico suele ser su conjunto de skills, herramientas e instrucciones. Un "agente de soporte" y un "agente de DevOps" pueden usar el mismo modelo y diferenciarse solo en eso:

> agente especializado = agente genérico + skills + herramientas
